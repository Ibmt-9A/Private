codeunit 51100 "ToolActions"
{
    Permissions = tabledata "Item Ledger Entry" = RDMI,
        tabledata "Warehouse Entry" = RDMI;

    procedure CorrectItem()
    var
        Item: Record Item;
        ItemLedgerEntry: Record "Item Ledger Entry";
        WareHouseEntry: Record "Warehouse Entry";
        w: Dialog;
    begin
        If (CompanyName <> 'SL Audio A/S (SLH)') then begin
            Error('This action is only allowed to run in SL Audio A/S (SLH)');
        end;
        If ItemLedgerEntry.get('2245072') then begin
            ItemLedgerEntry.Quantity := -41;
            ItemLedgerEntry."Invoiced Quantity" := -41;
            ItemLedgerEntry.Modify(False);
        end;
        If WareHouseEntry.get('2330992') then begin
            WareHouseEntry.Quantity := -54;
            WareHouseEntry."Qty. (Base)" := -54;
            WareHouseEntry.Modify(False);
        end;
        Message('Kørsel kørt færdig');
    end;
}
