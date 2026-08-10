pageextension 51000 "PTE_CompanyInformation" extends "Company Information"
{
    layout
    {
        addlast(General)
        {

        }
    }
    actions
    {
        addlast(General)
        {
            action(MyAction)
            {
                ApplicationArea = All;
                Caption = 'My Action';
                Image = Information;
                trigger OnAction()
                var
                    Item: Record Item;
                begin
                    Item.Reset();
                    If Item.FindSet() then begin
                        repeat
                            Item.CBXBool := true;
                            Item.Modify();
                        until Item.Next() = 0;
                    end;

                    Message('All items updated successfully.');
                end;
            }

        }
    }
}