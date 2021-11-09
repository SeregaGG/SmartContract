pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "BaseShopList.sol";

contract FillingShoppingListDeBot is BaseShopList {
    string purchaseTitle;

    function _menu() internal override {
        string sep = '----------------------------------------';
        Menu.select(
            format(
                "You have {}/{}/{} (Bought/Unbought/Total) things",
                summary.countOfBoughtPurhases,
                summary.countOfUnBoughtPurhases,
                summary.countOfBoughtPurhases + summary.countOfUnBoughtPurhases
            ),
            sep,
            [
                MenuItem("Add something else","",tvm.functionId(addPurchase)),
                MenuItem("Remove purchase from list","",tvm.functionId(removePurchaseFromList)),
                MenuItem("Show shopping list","",tvm.functionId(showList))
            ]
        );
    }

    function addPurchase(uint32 index) public {

        Terminal.input(tvm.functionId(savePurchaseTitle), "Enter purchase title: ", false);

    }

    function savePurchaseTitle(string value) public {

        purchaseTitle = value;
        Terminal.input(tvm.functionId(addPurchase_), "Enter number of purchases: ", false);
        
    }

    function addPurchase_(string value) public {
        
        optional(uint256) pubkey = 0;
        (uint res,) = stoi(value);
        ShoppingListInterface(listAddress).addPurchase {
            abiVer: 2,
            extMsg: true,
            sign: true,
            pubkey: pubkey,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(onSuccess),
            onErrorId: tvm.functionId(onError)
        } (purchaseTitle, uint64(res));
    }
}