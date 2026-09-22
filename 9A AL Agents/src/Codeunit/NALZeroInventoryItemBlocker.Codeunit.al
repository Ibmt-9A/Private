codeunit 50101 NALZeroInventoryItemBlocker
{
    trigger OnRun()
    begin
        BlockZeroInventoryItems();
    end;

    /// <summary>
    /// Loops through all inventory-type items and blocks (Blocked = true) every item with Inventory = 0.
    /// </summary>
    procedure BlockZeroInventoryItems()
    var
        Item: Record Item;
    begin
        Item.SetRange(Type, Item.Type::Inventory);
        Item.SetRange(Blocked, false);
        Item.SetAutoCalcFields(Inventory);
        if Item.FindSet(true) then begin
            repeat
                if Item.Inventory = 0 then begin
                    Item.Blocked := true;
                    Item.Modify(true);
                end;
            until Item.Next() = 0;
        end;
    end;
}
