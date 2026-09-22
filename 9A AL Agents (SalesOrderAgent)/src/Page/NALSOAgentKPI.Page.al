// Summary page shown when hovering over the NAL Sales Order Agent icon.
page 50101 NALSOAgentKPI
{
    PageType = CardPart;
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'NAL Sales Order Agent Summary';
    SourceTable = NALSOAgentKPI;
    Editable = false;
    Extensible = false;

    layout
    {
        area(Content)
        {
            cuegroup(KeyMetrics)
            {
                Caption = 'Key Performance Indicators';

                field(QuotesCreatedCount; Rec.QuotesCreatedCount)
                {
                    Caption = 'Sales Quotes Created';
                    ToolTip = 'Specifies the number of sales quotes created by the agent.';
                }
                field(OrdersCreatedCount; Rec.OrdersCreatedCount)
                {
                    Caption = 'Sales Orders Created';
                    ToolTip = 'Specifies the number of sales orders created by the agent.';
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        SalesHeader: Record "Sales Header";
        UserSecurityIDFilter: Text;
    begin
        if IsNullGuid(Rec."User Security ID") then begin
            UserSecurityIDFilter := Rec.GetFilter("User Security ID");
            if not Evaluate(Rec."User Security ID", UserSecurityIDFilter) then
                Error(AgentDoesNotExistErr);
        end;

        if not Rec.Get(Rec."User Security ID") then
            Rec.Insert();

        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Quote);
        SalesHeader.SetRange(SystemCreatedBy, Rec."User Security ID");
        Rec.QuotesCreatedCount := SalesHeader.Count();

        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        Rec.OrdersCreatedCount := SalesHeader.Count();

        Rec.Modify();
    end;

    var
        AgentDoesNotExistErr: Label 'The agent does not exist. Please check the configuration.';
}
