// Simple text prompt used to add a sales line without an item number, avoiding the item lookup that a Type/No./Description grid edit can trigger.
page 50105 NALSOAgentTextLineDialog
{
    PageType = StandardDialog;
    Caption = 'Add Text Line';
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            field(Description; Description)
            {
                ApplicationArea = All;
                Caption = 'Description';
                ToolTip = 'Specifies the free text to show on the sales line. No item lookup is performed on this text.';
                MultiLine = true;
            }
        }
    }

    procedure GetDescription(): Text[100]
    begin
        exit(Description);
    end;

    var
        Description: Text[100];
}
