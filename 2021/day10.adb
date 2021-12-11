-- --- Day 10: Syntax Scoring ---

with Ada.Containers; use Ada.Containers;
with Ada.Containers.Vectors;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

with Ada.Text_IO; use Ada.Text_IO;

procedure Day10 is
   package String_Vectors is new
     Ada.Containers.Vectors
       (Index_Type   => Natural,
        Element_Type => Unbounded_String);

   use String_Vectors;

   package Character_Vectors is new Ada.Containers.Vectors
      (Index_Type   => Natural,
       Element_Type => Character);

   use Character_Vectors;

   type Unsigned_64 is mod 2**64;

   package Integer_Vectors is new Ada.Containers.Vectors
      (Index_Type   => Natural,
       Element_Type => Unsigned_64);

   package Integer_Vectors_Sorting is new Integer_Vectors.Generic_Sorting;

   use Integer_Vectors;
   use Integer_Vectors_Sorting;

   function is_Open (C: Character) return Boolean is
   begin
      return C = '(' or else C = '{' or else C = '[' or else C = '<';
   end is_Open;

   function Matches (O: Character; C: Character) return Boolean is
   begin
      return (O = '(' and C = ')') or else( O = '{' and C = '}') or else (O = '[' and C = ']') or else (O = '<' and C = '>');
   end Matches;

   function Check_Syntax (Line : Unbounded_String) return Character_Vectors.Vector is
      Stack : Character_Vectors.Vector;
      P : Character;
   begin
      for I in 1..Length (Line) loop
         declare
            C : Character := Element (Line, I);
         begin
            if is_Open(C) then
               Stack.Prepend (C);
            else
               P := Stack.First_Element;
               Stack.Delete (0);
               if not Matches (P, C) then
                  Stack.Prepend (C);
                  return Stack;
               end if;
            end if;
         end;
      end loop;

      Stack.Prepend ('+');
      return Stack;
   end Check_Syntax;

   function Check_Syntax (Lines : String_Vectors.Vector) return Character_Vectors.Vector is
      Result : Character_Vectors.Vector;
      Line : Unbounded_String;
   begin
      for Line of Lines loop
         declare
            C : Character := Check_Syntax (Line).First_Element;
         begin
            if C /= '+' then
               Result.Append (C);
            end if;
         end;
      end loop;

      return Result;
   end Check_Syntax;

   function Syntax_Score (C : Character) return Integer is
      Result : Integer;
   begin
      case C is
         when ')' => Result := 3;
         when ']' => Result := 57;
         when '}' => Result := 1197;
         when '>' => Result := 25137;
         when others => Result := 0;
      end case;

      return Result;
   end Syntax_Score;

   function Completion_Score (C : Character) return Unsigned_64 is
      Result : Unsigned_64;
   begin
      case C is
         when '(' => Result := 1;
         when '[' => Result := 2;
         when '{' => Result := 3;
         when '<' => Result := 4;
         when others => Result := 0;
      end case;

      return Result;
   end Completion_Score;

   function Syntax_Score (Illegal_Characters : Character_Vectors.Vector) return Integer is
      Score : Integer := 0;
   begin
      for C of Illegal_Characters loop
         Score := Score + Syntax_Score (C);
      end loop;

      return Score;
   end Syntax_Score;

   function Completion_Score(Completing_Characters : Character_Vectors.Vector) return Unsigned_64 is
      Score : Unsigned_64 := 0;
   begin
      for C of Completing_Characters loop
         Score := Score * 5;
         Score := Score + Completion_Score (C);
      end loop;

      return Score;
   end Completion_Score;

   function Completion_Score(Lines : String_Vectors.Vector) return Unsigned_64 is
      Score : Unsigned_64 := 0;
      Scores : Integer_Vectors.Vector;
      Line : Unbounded_String;
   begin
      for Line of Lines loop
         declare
            Completing : Character_Vectors.Vector := Check_Syntax (Line);
         begin
            if Completing.First_Element = '+' then
               Score := Completion_Score (Completing);
               Scores.Append (Score);
            end if;
         end;
      end loop;

      Sort (Scores);
      return Scores.Element (Scores.Last_Index / 2);
   end Completion_Score;

   Input : File_Type;
   Nav_Subsystem : String_Vectors.Vector;
   Line : Unbounded_String;
begin
   Open (Input, In_File, "inputs/input10.txt");
   while not End_Of_File (Input) loop
      begin
         Line := To_Unbounded_String (Get_Line (Input));
         Nav_Subsystem.Append (Line);
      end;
   end loop;
   Close (Input);

   Put_Line(Integer'Image (Syntax_Score (Check_Syntax (Nav_Subsystem))));
   Put_Line(Unsigned_64'Image (Completion_Score (Nav_Subsystem)));
end Day10;

-- gnatmake day10.adb
-- ./day10
--  343863
--  2924734236
