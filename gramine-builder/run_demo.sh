#/bin/bash
if [ ! -f .env ]; then
    echo "Warning .env file not found copying defaults"
    cp .env.example .env
fi

echo "Running with SGX environment"
cat .env
echo 
echo 

docker compose -f docker-compose.yml down
kurtosis enclave rm -f prof-testnet
cd ..
kurtosis run --enclave prof-testnet --args-file gramine-builder/network_params.yaml . "{}" &
PID=$!
echo "Kurtosis PID" $PID

network_up="$(docker ps | grep cl-3-lighthouse)"
while [ "$network_up" == "" ]
do
    sleep 1
    network_up="$(docker ps | grep cl-3-lighthouse)"
done
cd gramine-builder
mkdir -p network/
rm -rf network/genesis/*
rm -rf network/jwt/*
kurtosis files download prof-testnet el_cl_genesis_data network/genesis
kurtosis files download prof-testnet jwt_file  network/jwt
docker compose -f docker-compose.yml up --build -d

wait $PID