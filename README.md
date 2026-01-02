![KineticLiquid](https://ibb.co/fzXWCKGs)

![KineticLiquid Background](https://ibb.co/fzJtP2gK)

# KineticLiquid SDK

Production-grade, Solana-native TypeScript SDK for KineticLiquid — a liquidity execution & loop engine designed for deterministic, risk-aware automation.

This SDK is infrastructure software: explicit error handling, deterministic routing decisions, and audit-friendly abstractions.

## Installation

```bash
npm install kineticliquid-sdk
```

## Design Principles

- **No hidden transactions**: the SDK never stores private keys and never signs without an explicit `wallet.signTransaction(...)`.
- **Deterministic execution**: routing selection and risk checks are deterministic for a given input set.
- **Fail-closed**: risk circuit breakers halt execution immediately.
- **Typed, explicit errors**: consumer code can reliably branch on error classes.
- **IDL-driven program interface**: instruction building and account decoding use the Anchor-compatible IDL in `src/idl/kineticliquid.json`.

## Architecture Overview

- **Client**
  - `src/client/KineticLiquidClient.ts`: single entry point, holds connection/program/wallet, exposes managers.
  - `src/client/ConnectionManager.ts`: deterministic send/confirm with retry.
- **Vaults**
  - `src/vaults/VaultManager.ts`: creates, fetches, and drives vault lifecycle (`initialize_vault`, `execute_loop`, `rebalance`, `unwind`, `close_vault`).
  - `src/vaults/Vault.ts`: non-custodial vault handle; provides `deposit`, `withdraw`, `rebalance`, `unwind`, `close`.
- **Risk (first-class)**
  - `src/risk/RiskEngine.ts`: oracle deviation, volatility thresholds, liquidity health hooks.
  - `src/risk/CircuitBreaker.ts`: immediate halt semantics.
  - `src/risk/OracleValidator.ts`: deviation + staleness enforcement.
- **Routing**
  - `src/routing/ExecutionRouter.ts`: deterministic multi-adapter quote selection.
  - `src/routing/DexAdapter.ts`: adapter interface for DEX integration.
- **Loops**
  - `src/loops/LoopBuilder.ts`: validates configuration and constructs a `LoopExecutor`.
  - `src/loops/LoopExecutor.ts`: orchestrates off-chain risk validation and triggers the canonical on-chain `execute_loop` entrypoint.

## Security Model

- **Key management**
  - The SDK never persists private keys.
  - All signing is explicit via the consumer-provided `wallet`.
- **On-chain validation**
  - PDA derivations are deterministic and verified before sending lifecycle instructions.
  - Program ID is never hard-coded; it is supplied by the consumer and injected into the IDL at runtime.
- **Risk controls**
  - Circuit breakers are enforced before any loop execution.
  - Oracle deviation and volatility checks are deterministic and typed.
- **Failure modes**
  - Errors are typed and surfaced; no silent failures.
  - Transactions are sent + confirmed; failures surface as deterministic errors.

## Usage

### Basic Client + Vault

```ts
import { Connection, PublicKey } from '@solana/web3.js';
import { KineticLiquidClient } from 'kineticliquid-sdk';

const connection = new Connection(process.env.RPC_URL!, 'confirmed');
const programId = new PublicKey(process.env.KINETICLIQUID_PROGRAM_ID!);

// wallet must implement: publicKey + signTransaction
const client = new KineticLiquidClient({
  connection,
  wallet,
  environment: 'mainnet',
  programId,
});

// Option A: pass the asset mint directly
const usdcMint = new PublicKey(process.env.USDC_MINT!);
const vault = await client.vaults.create({
  owner: wallet.publicKey,
  assetMint: usdcMint,
  maxOracleDeviationBps: 200,
  maxVolatilityBps: 500,
  maxSlippageBps: 100,
});

// Option B: resolve asset symbols via a user-provided registry (no hard-coded addresses)
// const client = new KineticLiquidClient({
//   connection,
//   wallet,
//   environment: 'mainnet',
//   programId,
//   assetRegistry: { resolveMint: (sym) => { ... } },
// });
// const vault = await client.vaults.create({ owner: wallet.publicKey, asset: 'USDC', ... })
```

### Build and Execute a Loop (Oracle-validated, then on-chain `execute_loop`)

```ts
const loop = client.loops.build({
  vault,
  maxRisk: 0.05,
  rebalanceInterval: 3600,
  oracle,
});

await loop.execute({
  minOutAmount: 0n,
  // optional swap stage (requires registered DEX adapters)
  // swap: { outMint: SOME_MINT, inAmount: 1_000_000n, maxSlippageBps: 100 },
});
```

## Observability

`KineticLiquidClient` emits structured events:

- `vault:health`
- `loop:state`
- `execution:record`

Consumers can stream these into metrics/logging systems and ensure there are no silent failures.

## Testing

- Unit tests: deterministic and RPC-free

```bash
npm run test:unit
```

- Integration tests: require a real RPC and a deployed KineticLiquid program

```bash
export KINETICLIQUID_RPC_URL=http://127.0.0.1:8899
export KINETICLIQUID_PROGRAM_ID=... # real deployed program id
INTEGRATION=1 npm run test:integration
```

## Legal Disclaimer

This SDK is provided “as is”, without warranty of any kind. You are responsible for validating correctness, security properties, and production suitability for your deployment and jurisdiction.
