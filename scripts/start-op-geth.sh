#!/bin/sh
set -eou

# Wait for the Bedrock flag for this network to be set.
echo "Waiting for Bedrock node to initialize..."
while [ ! -f /shared/initialized.txt ]; do
  sleep 1
done

if [ -z "${IS_CUSTOM_CHAIN+x}" ]; then
  if [ "$NETWORK_NAME" == "op-mainnet" ] || [ "$NETWORK_NAME" == "op-goerli" ]; then
    export EXTENDED_ARG="${EXTENDED_ARG:-} --rollup.historicalrpc=${OP_GETH__HISTORICAL_RPC:-http://l2geth:8545} --op-network=$NETWORK_NAME"
  else
    export EXTENDED_ARG="${EXTENDED_ARG:-} --op-network=$NETWORK_NAME"
  fi
fi

# Init genesis if custom chain
if [ -n "${IS_CUSTOM_CHAIN+x}" ]; then
  geth init --datadir="$BEDROCK_DATADIR" /chainconfig/genesis.json
fi

# Determine syncmode based on NODE_TYPE
if [ -z "${OP_GETH__SYNCMODE+x}" ]; then
  if [ "$NODE_TYPE" = "full" ]; then
    export OP_GETH__SYNCMODE="snap"
  else
    export OP_GETH__SYNCMODE="full"
  fi
fi

exec geth \
  --datadir="$BEDROCK_DATADIR" \
  --syncmode="$OP_GETH__SYNCMODE" \
  --gcmode="$NODE_TYPE" \
  --networkid 690 \
  --ipcdisable \
  --http \
  --http.port=8545 \
  --http.api="admin,engine,eth,web3,txpool,net,debug,net" \
  --http.addr="0.0.0.0" \
  --http.corsdomain="*" \
  --http.vhosts="*" \
  --ws \
  --ws.api="debug,eth,txpool,net,web3,engine" \
  --ws.port=8546 \
  --ws.addr="0.0.0.0" \
  --ws.origins="*" \
  --metrics \
  --metrics.influxdb \
  --metrics.influxdb.endpoint=http://influxdb:8086 \
  --metrics.influxdb.database=opgeth \
  --networkid=690 \
  --verbosity=3 \
  --authrpc.vhosts="*" \
  --authrpc.addr=0.0.0.0 \
  --authrpc.port=8551 \
  --authrpc.jwtsecret=/shared/jwt.txt \
  --rpc.allow-unprotected-txs \
  --gpo.minsuggestedpriorityfee=1000000 \
  --rollup.sequencerhttp="$BEDROCK_SEQUENCER_HTTP" \
  --rollup.disabletxpoolgossip=true \
  --port="${PORT__OP_GETH_P2P:-39393}" \
  --discovery.port="${PORT__OP_GETH_P2P:-39393}" \
  --db.engine=pebble \
  --nodiscover \
  --state.scheme=hash \
  $EXTENDED_ARG $@

