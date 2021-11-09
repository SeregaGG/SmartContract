pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;


interface Transactable {

    function sendTransaction(address dest, uint128 value, bool bounce, uint8 flags, TvmCell payload) virtual external;

} 