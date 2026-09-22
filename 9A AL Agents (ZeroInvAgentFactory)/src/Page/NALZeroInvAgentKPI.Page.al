// Summary page shown when hovering over the NAL Zero Inventory Agent icon.
page 50105 NALZeroInvAgentKPI
{
    PageType = CardPart;
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'NAL Zero Inventory Agent Summary';
    SourceTable = NALZeroInvAgentKPI;
    Editable = false;
    Extensible = false;

    layout
    {
        area(Content)
        {
            cuegroup(KeyMetrics)
            {
                Caption = 'Key Performance Indicators';

                field(ItemsBlockedCount; Rec.ItemsBlockedCount)
                {
                    Caption = 'Items Blocked';
                    ToolTip = 'Specifies the number of items currently blocked because their inventory is 0.';
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        Item: Record Item;
        UserSecurityIDFilter: Text;
    begin
        if IsNullGuid(Rec."User Security ID") then begin
            UserSecurityIDFilter := Rec.GetFilter("User Security ID");
            if not Evaluate(Rec."User Security ID", UserSecurityIDFilter) then
                Error(AgentDoesNotExistErr);
        end;

        if not Rec.Get(Rec."User Security ID") then
            Rec.Insert();

        Item.SetRange(Blocked, true);
        Rec.ItemsBlockedCount := Item.Count();
        Rec.Modify();
    end;

    var
        AgentDoesNotExistErr: Label 'The agent does not exist. Please check the configuration.';
}
