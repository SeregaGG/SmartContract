pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "../ShoppingStructs/PurchaseStruct.sol";
import "../ShoppingStructs/SummaryPurchasesStruct.sol";

interface ShoppingListInterface {

    function addPurchase(string name, uint64 count) external;

    function removePurchase(uint id) external;
    
    function buyPurchase(uint id, uint64 price) external;

    function getSummary() external view returns(SummaryPurchase);

    function getPurchases() external view returns(Purchase[]);

} 