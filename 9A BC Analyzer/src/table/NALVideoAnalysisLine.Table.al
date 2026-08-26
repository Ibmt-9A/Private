table 51002 NALVideoAnalysisLine
{
    Caption = 'Video Analysis Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; EntryNo; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
            TableRelation = NALVideoAnalysis.EntryNo;
        }
        field(2; LineNo; Integer)
        {
            Caption = 'Line No.';
            DataClassification = SystemMetadata;
        }
        field(3; LineType; Enum NALVideoAnalysisLineType)
        {
            Caption = 'Line Type';
            DataClassification = SystemMetadata;
        }
        field(4; Description; Text[2048])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(5; SequenceTime; Text[20])
        {
            Caption = 'Timestamp';
            DataClassification = SystemMetadata;
        }
        field(6; ScreenshotData; Blob)
        {
            Caption = 'Screenshot';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; EntryNo, LineNo)
        {
            Clustered = true;
        }
        key(LineType; EntryNo, LineType) { }
    }
}
