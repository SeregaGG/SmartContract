pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "BaseShopList.sol";

contract ShoppingDebot is BaseShopList {
    
    string purchaseTitle;
    
    uint purchaseID;
 
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
                MenuItem("Add to cart", "", tvm.functionId(addToCart)),
                MenuItem("Remove purchase from list", "", tvm.functionId(removePurchaseFromList)),
                MenuItem("Show shopping list", "", tvm.functionId(showList))
            ]
        );
    }

    function addToCart(uint32 index) public {

        if (summary.countOfBoughtPurhases + summary.countOfUnBoughtPurhases > 0) {

            Terminal.input(tvm.functionId(savePrice), "Enter number of purchases: ", false);

        } else {

            Terminal.print(0, "Sorry, you have no purchases to buy");
            _menu();
        }
        
    }

    function savePrice(string value) public {

        (purchaseID,) = stoi(value);
        Terminal.input(tvm.functionId(addToCart_), "Enter price: ", false);

    }

    function addToCart_(string value) public {
        
        optional(uint256) pubkey = 0;
        (uint res,) = stoi(value);
        ShoppingListInterface(listAddress).buyPurchase {
            abiVer: 2,
            extMsg: true,
            sign: true,
            pubkey: pubkey,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(onSuccess),
            onErrorId: tvm.functionId(onError)
        } (purchaseID, uint64(res));
    }
}