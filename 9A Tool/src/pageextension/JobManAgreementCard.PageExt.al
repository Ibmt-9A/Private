pageextension 62008 "PTE_JobManAgreementCard" extends JobManAgreementCard
{
    layout
    {
        addlast(General)
        {
            field(PTE_DynEmpType; Rec.PTE_DynEmpType)
            {
                ApplicationArea = all;
            }

        }
    }
}