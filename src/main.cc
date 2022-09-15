
// TODO: Change to const volatile pointers
#define PORTB ((unsigned char*)0x6000u)
#define PORTA ((unsigned char*)0x6001u)
#define DDRB ((unsigned char*)0x6002u)
#define DDRA ((unsigned char*)0x6003u)

#define E 0b10000000
#define RW 0b01000000
#define RS 0b00100000

extern const char hello_world[];

void lcd_wait();
void lcd_instruction(unsigned char inst);
void print_char(unsigned char c);

int main() {
  const char* p;

  *DDRB = 0b11111111;
  *DDRA = 0b11100000;

  lcd_instruction(0b00111000);  // Set 8-bit mode; 2-line display; 5x8 font
  lcd_instruction(0b00001110);  // Display on; cursor on; blink off
  lcd_instruction(
      0b00000110);  // Increment and shift cursor; don't shift display
  lcd_instruction(0b00000001);  // Clear display

  p = hello_world;
  while (*p) {
    print_char(*p++);
  }

  while (1)
    ;  // Wait here...
  return 0;
}

void lcd_wait() {
  unsigned char status;

  *DDRB = 0b00000000;  // Port B is input
  do {
    *PORTA = RW;
    *PORTA = RW | E;
    status = *PORTB;
  } while (status & 0b10000000);

  *PORTA = RW;
  *DDRB = 0b11111111;  // Port B is output */
}

void lcd_instruction(unsigned char inst) {
  lcd_wait();
  *PORTB = inst;
  *PORTA = 0u;  // Clear RS/RW/E bits
  *PORTA = E;   // Set E bit to send instruction
  *PORTA = 0u;  // Clear RS/RW/E bits
}

void print_char(unsigned char c) {
  lcd_wait();
  *PORTB = c;
  *PORTA = RS;      //  Set RS; Clear RW/E bits
  *PORTA = RS | E;  //  Set E bit to send instruction
  *PORTA = RS;      //  Clear E bits
}