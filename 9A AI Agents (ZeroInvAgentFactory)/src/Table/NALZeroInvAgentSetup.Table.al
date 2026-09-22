// Stores the agent instances of the NAL Zero Inventory Agent. The User Security ID links to the agent user created by the platform.
table 50102 NALZeroInvAgentSetup
{
    Access = Internal;
    Caption = 'NAL Zero Inventory Agent Setup';
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
            ToolTip = 'Specifies the unique identifier for the user.';
            DataClassification = SystemMetadata;
            Editable = false;
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
