#!/bin/sh
set -eou

# Wait for the Bedrock flag for this network to be set.
echo "Waiting for Bedrock node to initialize..."
while [ ! -f /shared/initialized.txt ]; do
  sleep 1
done

if [ -n "${IS_CUSTOM_CHAIN+x}" ]; then
  export EXTENDED_ARG="${EXTENDED_ARG:-} --rollup.config=/chainconfig/rollup.json"
else
  export EXTENDED_ARG="${EXTENDED_ARG:-} --network=$NETWORK_NAME --rollup.load-protocol-versions=true --rollup.halt=major"
fi

# Start op-node.




exec op-node \
  --l1=$OP_NODE__RPC_ENDPOINT \
  --l1.beacon.ignore \
  --l2=http://op-geth:8551 \
  --l2.jwt-secret=/shared/jwt.txt \
  --plasma.enabled \
  --plasma.da-server=https://da.redstonechain.com \
  --l1.trustrpc \
  --l1.rpckind=$OP_NODE__RPC_TYPE \
  --metrics.enabled \
  --metrics.addr=0.0.0.0 \
  --metrics.port=7300 \
  --rpc.addr=0.0.0.0 \
  --rpc.port=9545 \
  --rpc.enable-admin \
  --p2p.bootnodes=enr:-J24QIpQjoWf3sSMiDk3CGkA3FaUVadLzMxuJHfEvkE5Q9FbFRFG5RPFxCIw0b7boSCjJ_vVc8pX4Ue-tVjsu4ou7-qGAY8vobQSgmlkgnY0gmlwhDTWuneHb3BzdGFja4OyBQCJc2VjcDI1NmsxoQMTlWaih1oq9kVe5yYJ5N1C0IAqx4mpxJyl8L17-y4csYN0Y3CCJAaDdWRwgiQG,enr:-J24QF7mHVOC1BiVPXWl2IC_FUbSHeuci1NyCd78M7465KOIWeSwViFJePXBManyOebiwk-SA5hESbORtXKWYtw73WOGAY8vnYXtgmlkgnY0gmlwhDaqpwSHb3BzdGFja4OyBQCJc2VjcDI1NmsxoQLNE3bfX7m_0n1lEitv4YKTTsTvZr0jmTXJS2x6rGSI9IN0Y3CCJAaDdWRwgiQG,enr:-J24QPBqZvUSnkzKgjnkYB_VvLaFW3xTMvOZeYIX1d5PAnKYIeIGCU206MOdVs_WyYmSUvaPIwXmRvyaKZWlJJYh0KGGAY8vlbMHgmlkgnY0gmlwhCLwOnqHb3BzdGFja4OyBQCJc2VjcDI1NmsxoQIW0taIKXJ_N2bUMmUL2QQzj6l9rk9sR_9YaWY2lazOwoN0Y3CCJAaDdWRwgiQG \
  --rollup.config=/chainconfig/rollup.json   \
  --syncmode=execution-layer \
  $EXTENDED_ARG $@




