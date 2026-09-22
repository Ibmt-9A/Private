profile NALSOAgentProfile
{
    Caption = 'NAL Sales Order Agent';
    Description = 'Profile used by the NAL Sales Order Agent.';
    RoleCenter = NALSOAgentRoleCenter;
    Customizations = NALSOAgentSalesQuotesCust, NALSOAgentSalesQuoteCust, NALSOAgentCustomerListCust, NALSOAgentItemListCust;
}
