pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "../HasConstructorWithPubKey.sol";

import "../Interfaces/ShoppingListInterface.sol";
import "../Interfaces/Transactable.sol";


contract ShoppingList is AShoppingList, ShoppingListInterface {

    Purchase[] purchase;
    mapping (uint => Purchase) purchases;
    uint lastPurchase = 0;
    SummaryPurchase summary = SummaryPurchase(0, 0, 0);

    uint ownerPubkey;

    modifier onlyOwner() {

        require(msg.pubkey() == ownerPubkey, 101);
        tvm.accept();
        _;
    }

    modifier isExistsAndNotBougth(uint id) {

        require(purchases.exists(id), 101);
        require(!purchases[id].isBought, 101);
        _;
    }

    constructor(uint256 pubkey) AShoppingList(pubkey) public {

        require(tvm.pubkey() != 0, 101);

        tvm.accept();

        ownerPubkey = pubkey;
    }

    function addPurchase(string name, uint64 count) public override onlyOwner {

        summary.countOfUnBoughtPurhases += 1;
        purchases[lastPurchase] = Purchase(lastPurchase, name, count, now, false, 0);
        lastPurchase++;
    }

    function removePurchase(uint id) public override onlyOwner {
        
        require(purchases.exists(id), 101);
        
        if(purchases[id].isBought) {

            summary.countOfBoughtPurhases -= 1;

        } else {

            summary.countOfUnBoughtPurhases -= 1;
        }

        delete purchases[id];
    }


    function buyPurchase(uint id, uint64 price) public override onlyOwner isExistsAndNotBougth(id) {

        purchases[id].isBought = true;
        purchases[id].price = price;

        summary.countOfBoughtPurhases += 1;
        summary.countOfUnBoughtPurhases -= 1;
        summary.totalPrice += price;
    }

    function getPurchases() public override view returns(Purchase[]) {
        
        Purchase[] returnedList;

        for((uint id, Purchase task) : purchases) {

            returnedList.push(purchases[id]);
        }

        return returnedList;
    }

    function getSummary() public override view returns(SummaryPurchase) {
        
        return summary;
    }

}