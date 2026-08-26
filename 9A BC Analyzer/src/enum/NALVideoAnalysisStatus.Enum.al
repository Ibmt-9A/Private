enum 51000 NALVideoAnalysisStatus
{
    Extensible = true;
    Caption = 'Video Analysis Status';

    value(0; New)
    {
        Caption = 'New';
    }
    value(1; Processing)
    {
        Caption = 'Processing';
    }
    value(2; Completed)
    {
        Caption = 'Completed';
    }
    value(3; Error)
    {
        Caption = 'Error';
    }
}
