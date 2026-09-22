// KPI data shown when hovering over the NAL Sales Order Agent icon.
table 50101 NALSOAgentKPI
{
    Access = Internal;
    Caption = 'NAL Sales Order Agent KPI';
    DataClassification = CustomerContent;
    InherentEntitlements = RIMDX;
    InherentPermissions = RIMDX;
    ReplicateData = false;
    DataPerCompany = false;

    fields
    {
        field(1; "User Security ID"; Guid)
        {
            Caption = 'User Security ID';
            ToolTip = 'Specifies the unique identifier for the agent user.';
            DataClassification = EndUserPseudonymousIdentifiers;
            Editable = false;
        }
        field(10; QuotesCreatedCount; Integer)
        {
            Caption = 'Sales Quotes Created';
            ToolTip = 'Specifies the number of sales quotes created by the agent.';
            DataClassification = CustomerContent;
        }
        field(11; OrdersCreatedCount; Integer)
        {
            Caption = 'Sales Orders Created';
            ToolTip = 'Specifies the number of sales orders created by the agent.';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; "User Security ID")
        {
            Clustered = true;
        }
    }
}
