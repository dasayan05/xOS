ENTRY(StageTwoEntry)
OUTPUT_FORMAT(binary)

SECTIONS
{
     . = 0x0000;
     .text :
     {
          stage2.o (.text)
          * (EXCLUDE_FILE(stage2.o) .text)
     }
     .data :
     {
          * (.data)
     }
}
