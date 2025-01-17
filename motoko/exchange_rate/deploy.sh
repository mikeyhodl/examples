#!/bin/bash

# Call the script with deploy.sh {network}
if [[ $# -lt 1 ]]; then
    echo "Number of arguments supplied not correct. Call this script: \
    ./deploy.sh {env} \
    env should be one of the networks configured in dfx.json."
    exit 1
fi

ENV=$1

bash ./cleanup.sh $ENV

# Copy UI assets from rust folder to here
cp -r ../../rust/exchange_rate/src/frontend src/frontend
cp ../../rust/exchange_rate/rollup.config.js .
cp ../../rust/exchange_rate/package.json .

cargo install cargo-audit
npm install

if [[ $ENV == "local" ]]; then

    # Check DFX version
    version=$(dfx -V | sed 's/dfx\ //g' | sed 's/-.*$//g')
    if [[ "$version" < "0.12.0" ]]; then
        echo "dfx 0.12.0 or above required. Please do: dfx upgrade"
        exit 1
    fi
    
    # Start local replica
    dfx start --background
fi

# Deploy exchange_rate and exchange_rate_assets
dfx deploy --network "$ENV"
