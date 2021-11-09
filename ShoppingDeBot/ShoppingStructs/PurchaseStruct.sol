pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

struct Purchase {

    uint id;
    string name;
    uint64 count;
    uint64 creationDate;
    bool isBought;
    uint64 price;

}