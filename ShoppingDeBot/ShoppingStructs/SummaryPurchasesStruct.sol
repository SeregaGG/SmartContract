pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

struct SummaryPurchase {

    uint64 countOfBoughtPurhases;
    uint64 countOfUnBoughtPurhases;
    uint64 totalPrice;
    
}