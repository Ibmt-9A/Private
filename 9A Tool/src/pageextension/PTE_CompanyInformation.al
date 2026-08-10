pageextension 51100 "PTE_CompanyInformation" extends "Company Information"
{
    layout
    {
        addlast(General)
        {

        }
    }
    actions
    {
        addlast(Processing)
        {
            action(UpdateItemAction)
            {
                ApplicationArea = All;
                Caption = 'Update Item ction';
                Image = UpdateDescription;
                trigger OnAction()
                var
                    Item: Record Item;
                    w: Dialog;
                begin
                    w.Open('Updating items #1##################');
                    Item.Reset();
                    If Item.FindSet() then begin
                        repeat
                            w.Update(1, Item."No.");
                            Item.CBXBool := true;
                            Item.Modify();
                        until Item.Next() = 0;
                    end;

                    w.Close();

                    Message('All items updated successfully.');
                end;
            }

        }
    }
}