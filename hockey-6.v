module hockey(

    input clk,
    input rst,
    
    input BTNA,
    input BTNB,
    
    input [1:0] DIRA,
    input [1:0] DIRB,
    
    input [2:0] YA,
    input [2:0] YB,
   
    output reg LEDA,
    output reg LEDB,
    output reg [4:0] LEDX,
    
    output reg [6:0] SSD7,
    output reg [6:0] SSD6,
    output reg [6:0] SSD5,
    output reg [6:0] SSD4, 
    output reg [6:0] SSD3,
    output reg [6:0] SSD2,
    output reg [6:0] SSD1,
    output reg [6:0] SSD0   
    
    );
    
    reg[3:0] state;
    reg[1:0] score_A, score_B;
    //reg[2:0] display_A, display_B;
    reg[1:0] dirY;
    // Other internal signals and variables
    reg [1:0] turn;  // 0: Player A's turn, 1: Player B's turn
    reg [6:0] timer;
    reg [2:0] X_COORD, Y_COORD;


    parameter IDLE_STATE = 4'b0001;
    parameter DISPLAY_SCORE = 4'b0010;
    parameter HIT_A = 4'b0011;
    parameter HIT_B = 4'b0100;
    parameter SEND_A = 4'b0101;
    parameter SEND_B = 4'b0110;
    parameter GOAL_A = 4'b0111;
    parameter GOAL_B = 4'b1000;
    parameter RESP_A = 4'b1001;
    parameter RESP_B = 4'b1010;
    parameter END_STATE = 4'b1011;

    // you may use additional always blocks or drive SSDs and LEDs in one always block
    // for state machine and memory elements 
    always @(posedge clk or posedge rst)
    begin
        
            if (rst)
            begin
              state <= IDLE_STATE;
              turn <= 0;
              timer <= 7'b0000000;
              X_COORD <= 3'b000;
              Y_COORD <= 3'b000;
              score_A <= 2'b00;
              score_B <= 2'b00;
              dirY <= 2'b00;
            end
            else begin
            if (rst) begin
                // Initialization code goes here
                state <= IDLE_STATE;
            end else begin
                // State transition logic goes here
                case (state)
                    IDLE_STATE: begin
                        // Handle idle state actions
                        // Check for button presses and transition to respective player's turn
                        if (BTNA) begin
                            turn <= 0;
                            state <= DISPLAY_SCORE;
                           
                        end else if (BTNB) begin
                            turn = 1;
                            state <= DISPLAY_SCORE;
                           
                        end else begin
                            // Stay in idle state
                            state <= IDLE_STATE;
                        end
        
                    end
        
           
        
                    DISPLAY_SCORE: begin
                      if(timer < 100) begin 
                        timer <= timer + 1;
                        state <= DISPLAY_SCORE;
                      end else begin
                        timer <= 7'b0000000;
                        if(score_A != 3 || score_B != 3) begin
                          if (turn == 0 ) begin
                            state <= HIT_A;
                          end else if (turn == 1) begin 
                            state <= HIT_B;
                        end
                        end else begin
                          state <= DISPLAY_SCORE;
                        end
                      end
                    end
            
        
                    HIT_A: begin
                      if (BTNA && YA < 3'b101) begin
                        // Set puck coordinates and direction
                        X_COORD <= 3'b000;
                        Y_COORD <= YA;
                        dirY <= DIRA;  // Direction is from player A to B
                        state <= SEND_B;  // Transition back to idle state
                        
                      end else begin
                        // Transition back to player A's turn if conditions are not met
                        state <= HIT_A;
                      end
                    end
        
                    HIT_B: begin
                      if (BTNB && YB < 5) begin
                       
                        // Set puck coordinates and direction
                        X_COORD <= 3'b100;
                        Y_COORD <= YB;
                        dirY <= DIRB;  // Direction is from player B to A
                        state <= SEND_A;  // Transition back to idle state
                    end else begin
                        // Transition back to player B's turn if conditions are not met
                        state <= HIT_B;
                        end
                    end
              
                    SEND_A: begin
                        if (timer < 100) begin
                            timer <= timer + 1;
                            state <= SEND_A;
                        end else begin
                          timer <= 7'b0000000;
                            case (dirY)
                              2'b10: begin
                              if (Y_COORD == 0) begin
                                dirY <= 2'b01;
                                Y_COORD <= Y_COORD + 1;
                                if (X_COORD > 1) begin
                                  X_COORD <= X_COORD - 1;
                                  state <= SEND_A;
                                end else begin
                                  X_COORD <= 3'b000;
                                  state <= RESP_A;
                                end
                              end else begin
                                Y_COORD <= Y_COORD - 1;
                                
                                if (X_COORD > 1) begin
                                  X_COORD <= X_COORD - 1;
                                  state <= SEND_A;
                                end else begin
                                  X_COORD <= 3'b000;
                                 
                                  state <= RESP_A;
                                end
                                end
                              end
                              2'b01: begin
                                if (Y_COORD == 4) begin
                                  dirY <= 2'b10;
                                  
                                  Y_COORD <= Y_COORD - 1;
                                  if (X_COORD > 1) begin
                                    
                                    X_COORD <= X_COORD - 1;
                                    state <= SEND_A;
                                  end else begin
                                    X_COORD <= 3'b000;
                                    state <= RESP_A;
                                  end
                              end else begin
                                Y_COORD <= Y_COORD + 1;
                                
                                if (X_COORD > 1) begin
                                  
                                  X_COORD <= X_COORD - 1;
                                  state <= SEND_A;
                                end else begin
                                  X_COORD <= 3'b000;
                                  
                                  state <= RESP_A;
                                end
                                end
                              end
                              2'b00: begin
                              if (X_COORD > 1) begin
                                X_COORD <= X_COORD - 1;
                                state <= SEND_A;
                              end else begin
                                X_COORD <= 3'b000;
                                
                                state <= RESP_A;
                              end
                            end
                            default: 
                            state <= SEND_A;
                            endcase
                        end
                    end
        
                    SEND_B : begin
                      
                        if (timer < 100) begin
                            timer <= timer + 1;
                            state <= SEND_B;
                        end else begin
                          timer <= 7'b0000000;
                            case (dirY)
                            2'b10: begin
                              if (Y_COORD == 0) begin
                                dirY <= 2'b01;
                                Y_COORD <= Y_COORD + 1;
                                if(X_COORD < 3) begin
                                  X_COORD <= X_COORD + 1;
                                  state <= SEND_B;
                                end else begin
                                  X_COORD <= 3'b100;
                                  state <= RESP_B;
                              end 
                            end else begin
                                Y_COORD <= Y_COORD - 1;
                                if(X_COORD < 3) begin
                                  X_COORD <= X_COORD + 1;
        
                                  state <= SEND_B;
                                end else begin
                                  X_COORD <= 3'b100;
                                  state <= RESP_B;
                              end
                            end
                          end
                            2'b01: begin
                              if (Y_COORD == 4) begin
                                dirY <= 2'b10;
                                Y_COORD <= Y_COORD - 1;
                                if(X_COORD < 3) begin
                                  X_COORD <= X_COORD + 1;
                                  state <= SEND_B;
                                end else begin
                                  X_COORD <= 3'b100;
                                  state <= RESP_B;
                              end 
                            end else begin
                                Y_COORD <= Y_COORD + 1;
                                if(X_COORD < 3) begin
                                  X_COORD <= X_COORD + 1;
                                  state <= SEND_B;
                                end else begin
                                  X_COORD <= 3'b100;
                                  state <= RESP_B;
                              end
                            end
                           end 
                          
                            2'b00: begin
                              if(X_COORD < 3) begin
                                X_COORD <= X_COORD + 1;
                                state <= SEND_B;
                              end else begin
                                X_COORD <= 3'b100;
                                state <= RESP_B;
                              end
                            end
                            default: 
                            state <= SEND_B;
                          endcase  
                        end
                    end
        
        
                    RESP_A: begin
                        if(timer < 100) begin
                            if(BTNA && Y_COORD == YA) begin
                              X_COORD <= 1;
                              timer <= 7'b0000000;
                              case (DIRA)
                                2'b10: begin
                                    if (Y_COORD == 0) begin
                                      dirY <= 2'b01;
                                      Y_COORD <= Y_COORD + 1;
                                      state <= SEND_B;
                                    end else begin
                                        dirY <= DIRA;
                                        Y_COORD <= Y_COORD - 1;
                                        state <= SEND_B;
                                    end
                                  end
                                  2'b01: begin
                                    if (Y_COORD == 4) begin
                                      dirY <= 2'b10;
                                      Y_COORD <= Y_COORD - 1;
                                      state <= SEND_B;
                                    end else begin
                                        dirY <= DIRA;
                                        Y_COORD <= Y_COORD + 1;
                                        state <= SEND_B;
                                    end
                                  end
                                  2'b00: begin
                                    dirY <= DIRA;
                                    state <= SEND_B;
                                  end
                                  default: begin
                                  dirY <= DIRA;
                                  state <= RESP_A;
                                  end
                                  
                                endcase
                            end else begin
                                timer <= timer + 1;
                                state <= RESP_A;
                            end
       
                        end else begin
                            timer <= 7'b0000000;
                            score_B <= score_B + 1;
                            state <= GOAL_B;
                        end 
                    end
        
                    RESP_B: begin
                        if(timer < 100) begin
                            
                            if(BTNB && Y_COORD == YB) begin
                              X_COORD <= 3;
                              timer <= 7'b0000000;
                              
                                case (DIRB)
                                2'b10: begin
                                    if (Y_COORD == 0) begin
                                      dirY <= 2'b01;
                                      Y_COORD <= Y_COORD + 1;
                                      state <= SEND_A;
                                    end else begin
                                      dirY <= DIRB;
                                      Y_COORD <= Y_COORD - 1;
                                      state <= SEND_A;
                                    end
                                  end
                                  2'b01: begin //ycord 3 girliyor
                                    if (Y_COORD == 4) begin
                                      dirY <= 2'b10;
                                      Y_COORD <= Y_COORD - 1;
                                      state <= SEND_A;
                                    end else begin
                                        dirY <= DIRB;
                                        Y_COORD <= Y_COORD + 1;
                                        state <= SEND_A;
                                    end
                                  end
                                  2'b00: begin
                                    dirY <= DIRB;
                                    state <= SEND_A;
                                  end
                                  default: begin
                                  dirY <= DIRB;
                                  state <= RESP_B;
                                  end
                                endcase
                            end else begin
                                timer <= timer + 1;
                                state <= RESP_B;
                            end
        
                        end else begin
                            timer <= 7'b0000000;
                            score_A <= score_A + 1; 
                            state <= GOAL_A;
                        end 
                    end
        
                    GOAL_A: begin 
                      
                        if (timer < 100) begin
                            timer <= timer + 1;
                            state <= GOAL_A;
                        end else begin
                            timer <= 7'b0000000;
                            if(score_A == 3) begin
                                turn <= 0;
                                state <= END_STATE;
                            end else begin
                                state <= HIT_B;
                            end
        
                        end
                    end
        
                    GOAL_B: begin
                        if (timer < 100) begin
                            timer <= timer + 1;
                            state <= GOAL_B;
                        end else begin
                            timer <= 7'b0000000;
                            if(score_B == 3) begin
                                turn <= 1;
                                state <= END_STATE;
                            end else begin
                                state <= HIT_A;
                            end
        
                        end
                    end
                    END_STATE: begin
                       
                        if (timer < 100)begin
                            timer <= timer + 1;
                        end
    
    
                        else begin
                            timer = 0;
                        end
    
                        state <= END_STATE;
                    end
    
                    default:
                    begin
                        state <= IDLE_STATE;
                    end
                endcase
              end
            end
          end
    


    // for SSDs
    always @ (*)
   begin
        
        case(state)
        IDLE_STATE: begin // en bastaki 0-0  sonra da onu silip y coord displayleme 
            
            //SSD0 = 7'b1111111;//B
            //SSD1 = 7'b1111111;//dash
            //SSD2 = 7'b1111111;//A
            SSD3 = 7'b1111111;
            SSD4 = 7'b1111111; // s�f�r
            SSD5 = 7'b1111111;
            SSD6 = 7'b1111111;
            SSD7 = 7'b1111111;
            if((BTNA ==0) & (BTNB==0)) begin
               SSD0 = 7'b1100000;//B
               SSD1 = 7'b1111110;//dash
               SSD2 = 7'b0001000;//A
               //SSD3 = 7'b1111111;
               //SSD4 = 7'b1111111; // s�f�r
               //SSD5 = 7'b1111111;
               //SSD6 = 7'b1111111;
               //SSD7 = 7'b1111111;
               
            end else begin // burda hangi butona bas�ld�ysa onun ledi yanacak
                if (timer < 100 )begin //2 saniye 100 oluyo
                  SSD0 = 7'b0000001; //0
                  SSD1 = 7'b1111110; // tire
                  SSD2 = 7'b0000001; //0
                  //SSD3 = 7'b1111111; //kapali
                  //SSD4 = 7'b1111111;
                  //SSD5 = 7'b1111111;
                  //SSD6 = 7'b1111111;
                  //SSD7 = 7'b1111111;
                  end else begin
                      SSD0 = 7'b1111111; //0
                      SSD1 = 7'b1111111; // tire
                      SSD2 = 7'b1111111; //0
                      //SSD3 = 7'b1111111; //kapali
                      //SSD4 = 7'b1111111;
                      //SSD5 = 7'b1111111;
                      //SSD6 = 7'b1111111;
                      //SSD7 = 7'b1111111;
                end
          end
        end
        
        DISPLAY_SCORE: begin
          
          SSD1 = 7'b1111110;
          SSD3 = 7'b1111111;
          SSD4 = 7'b1111111; 
          SSD5 = 7'b1111111;
          SSD6 = 7'b1111111;
          SSD7 = 7'b1111111;
         case(score_A) 
         2'b00: SSD2 = 7'b0000001;
         2'b01: SSD2 = 7'b1001111;
         2'b10: SSD2 = 7'b0010010;
         2'b11: SSD2 = 7'b0000110;
         default: SSD2 = 7'b1111111;
         endcase
         
         case(score_B)
         2'b00: SSD0 = 7'b0000001; // 0
         2'b01: SSD0 = 7'b1001111; // 1
         2'b10: SSD0 = 7'b0010010; // 2
         2'b11: SSD0 = 7'b0000110; // 3
         default: SSD0 = 7'b1111111;
         endcase
        end
        
    HIT_A:
    begin
      SSD0 = 7'b1111111; //0- yaniyo 1-yanmiyo
      SSD1 = 7'b1111111;
      SSD2 = 7'b1111111;
      SSD3 = 7'b1111111;
      SSD5 = 7'b1111111;
      SSD6 = 7'b1111111;
      SSD7 = 7'b1111111;

      case (YA)
        3'b000: SSD4 = 7'b0000001;
        3'b001: SSD4 = 7'b1001111; // 1
        3'b010: SSD4 = 7'b0010010; // 2
        3'b011: SSD4 = 7'b0000110; // 3
        3'b100: SSD4 = 7'b1001100; //4
        default: SSD4 = 7'b1111111;
      endcase
        
    end
    
    HIT_B:
    begin
      SSD0 = 7'b1111111; //0- yaniyo 1-yanmiyo
      SSD1 = 7'b1111111;
      SSD2 = 7'b1111111;
      SSD3 = 7'b1111111;
      SSD5 = 7'b1111111;
      SSD6 = 7'b1111111;
      SSD7 = 7'b1111111;

      case (YB)
        3'b000: SSD4 = 7'b0000001;
        3'b001: SSD4 = 7'b1001111; // 1
        3'b010: SSD4 = 7'b0010010; // 2
        3'b011: SSD4 = 7'b0000110; // 3
        3'b100: SSD4 = 7'b1001100; //4
        default: SSD4 = 7'b1111111;
      endcase
    end 
    
        SEND_A: begin
          SSD0 = 7'b1111111; //0- yaniyo 1-yanmiyo
          SSD1 = 7'b1111111;
          SSD2 = 7'b1111111;
          SSD3 = 7'b1111111;
          SSD5 = 7'b1111111;
          SSD6 = 7'b1111111;
          SSD7 = 7'b1111111;
          case(Y_COORD) 
          3'b000: SSD4 = 7'b0000001; 
          3'b001: SSD4 = 7'b1001111;
          3'b010: SSD4 = 7'b0010010; 
          3'b011: SSD4 = 7'b0000110; 
          3'b100: SSD4 = 7'b1001100; 
          default:  SSD4 = 7'b1111111; 
          endcase
        end
        SEND_B: begin
          SSD0 = 7'b1111111; //0- yaniyo 1-yanmiyo
          SSD1 = 7'b1111111;
          SSD2 = 7'b1111111;
          SSD3 = 7'b1111111;
          SSD5 = 7'b1111111;
          SSD6 = 7'b1111111;
          SSD7 = 7'b1111111;
          case(Y_COORD) 
          3'b000: SSD4 = 7'b0000001; 
          3'b001: SSD4 = 7'b1001111;
          3'b010: SSD4 = 7'b0010010; 
          3'b011: SSD4 = 7'b0000110; 
          3'b100: SSD4 = 7'b1001100; 
          default:  SSD4 = 7'b1111111; 
          
          endcase
        end
        RESP_A: begin
          SSD0 = 7'b1111111; //0- yaniyo 1-yanmiyo
          SSD1 = 7'b1111111;
          SSD2 = 7'b1111111;
          SSD3 = 7'b1111111;
          SSD5 = 7'b1111111;
          SSD6 = 7'b1111111;
          SSD7 = 7'b1111111;
          case(Y_COORD) 
          3'b000: SSD4 = 7'b0000001; 
          3'b001: SSD4 = 7'b1001111; 
          3'b010: SSD4 = 7'b0010010; 
          3'b011: SSD4 = 7'b0000110; 
          3'b100: SSD4 = 7'b1001100; 
          default:  SSD4 = 7'b1111111; 
          endcase
        end

        RESP_B: begin
          SSD0 = 7'b1111111; //0- yaniyo 1-yanmiyo
          SSD1 = 7'b1111111;
          SSD2 = 7'b1111111;
          SSD3 = 7'b1111111;
          SSD5 = 7'b1111111;
          SSD6 = 7'b1111111;
          SSD7 = 7'b1111111;
          
          case(Y_COORD) 
          3'b000: SSD4 = 7'b0000001; 
          3'b001: SSD4 = 7'b1001111; 
          3'b010: SSD4 = 7'b0010010; 
          3'b011: SSD4 = 7'b0000110; 
          3'b100: SSD4 = 7'b1001100; 
          default:  SSD4 = 7'b1111111; 
          endcase
        end

        GOAL_A: begin
        SSD1 = 7'b1111110; // dash
        SSD3 = 7'b1111111;
        SSD4 = 7'b1111111;
        SSD5 = 7'b1111111;
        SSD6 = 7'b1111111;
        SSD7 = 7'b1111111;
        case(score_A)
             2'b00: SSD2 = 7'b0000001;
             2'b01: SSD2 = 7'b1001111;
             2'b10: SSD2 = 7'b0010010;
             2'b11: SSD2 = 7'b0000110;
             default: SSD2 = 7'b1111111;
        endcase
        case(score_B)
             2'b00: SSD0 = 7'b0000001;
             2'b01: SSD0 = 7'b1001111;
             2'b10: SSD0 = 7'b0010010;
             2'b11: SSD0 = 7'b0000110;
             default: SSD0 = 7'b1111111;
        endcase
        end
        
        GOAL_B: begin
        SSD1 = 7'b1111110; // dash
        SSD3 = 7'b1111111;
        SSD4 = 7'b1111111;
        SSD5 = 7'b1111111;
        SSD6 = 7'b1111111;
        SSD7 = 7'b1111111;

        case(score_A)
             2'b00: SSD2 = 7'b0000001;
             2'b01: SSD2 = 7'b1001111;
             2'b10: SSD2 = 7'b0010010;
             2'b11: SSD2 = 7'b0000110;
             default: SSD2 = 7'b1111111;
        endcase
        case(score_B)
             2'b00: SSD0 = 7'b0000001;
             2'b01: SSD0 = 7'b1001111;
             2'b10: SSD0 = 7'b0010010;
             2'b11: SSD0 = 7'b0000110;
             default: SSD0 = 7'b1111111;
        endcase
        end
        
        
        END_STATE: begin
          SSD3 = 7'b1111111;
          SSD5 = 7'b1111111;
          SSD6 = 7'b1111111;
          SSD7 = 7'b1111111;
          if(score_A == 3) begin
            SSD4 = 7'b0001000;
            SSD2 = 7'b0000110;
            SSD1 = 7'b1111110;
            case(score_B)
              2'b00 : SSD0 = 7'b0000001;
              2'b01 : SSD0 = 7'b1001111;
              2'b10 : SSD0 = 7'b0010001;
              2'b11 : SSD0 = 7'b0000001;
              default: SSD0 = 7'b1111111;
            endcase
          end 
          else if(score_B == 3) begin
            SSD4 = 7'b1100000;
            SSD0 = 7'b0000110;
            SSD1 = 7'b1111110; //  -
            case(score_A)
              2'b00 : SSD2 = 7'b0000001;
              2'b01 : SSD2 = 7'b1001111;
              2'b10 : SSD2 = 7'b0010001;
              2'b11 : SSD2 = 7'b0000001;
              default: SSD2 = 7'b1111111;
            endcase   
        end 
        else begin
        SSD1 = 7'b1111110;
        SSD2 = 7'b1111111;
        end
      end 
      default:
      begin
          SSD0 = 7'b1111111; //0- yaniyo 1-yanmiyo
          SSD1 = 7'b1111111;
          SSD2 = 7'b1111111;
          SSD3 = 7'b1111111;
          SSD4 = 7'b1111111;
          SSD5 = 7'b1111111;
          SSD6 = 7'b1111111;
          SSD7 = 7'b1111111;
        
      end
      endcase
      
   end
      




// for LEDs
  always @ (*)
  begin
      // Reset or initialize LED-related signals and variables here
      LEDA = 1'b0; //0 ve 15 urdakiler
      LEDB = 1'b0;
      LEDX = 5'b00000;

    case (state)
      IDLE_STATE: begin
        if(BTNA ==0 && BTNB==0)begin
            LEDA = 1'b1; //0 ve 15 urdakiler
            LEDB = 1'b1;
            LEDX = 5'b00000; 
        end
        else begin
            if (timer < 100 )begin
                LEDX = 5'b11111; //tum ledler acik 2 sn boyunca
                //SSD 0 olarak y coord g?stericek!!!!!!!
                LEDA = 1'b0; //0 ve 15 urdakiler        
                LEDB = 1'b0; //kapatiyoruz
            end
            else begin
                LEDX = 5'b00000; //SSD de skor kapat
           
                if (BTNA ==1)begin
                    LEDA = 1'b1; //0 ve 15 surdakiler        
                    LEDB = 1'b0; //kapatiyoruz
                end
                else if (BTNB==1) begin
                    LEDB = 1'b1;
                    LEDA = 1'b0; //0 ve 15 urdakiler               
                end
                else begin
                LEDA = 1'b0;
                LEDB = 1'b0;
                LEDX = 1'b0;
                end
            end   
        end  
      end

    HIT_A:
    begin
        LEDA = 1'b1; //0 ve 15 surdakiler        
        LEDB = 1'b0; //kapatiyoruz
        LEDX = 5'b00000;
    end
    
    HIT_B:
    begin
        LEDB = 1'b1;
        LEDA = 1'b0; //0 ve 15 urdakiler
        LEDX = 5'b00000;
    end 
    
    SEND_A:

    begin
      LEDA = 0;
        // LED logic for HIT_A state
      case (X_COORD)
      3'b000: LEDX = 5'b10000; // LD9
      3'b001: LEDX = 5'b01000; // LD8
      3'b010: LEDX = 5'b00100; // LD7
      3'b011: LEDX = 5'b00010; // LD6
      3'b100: LEDX = 5'b00001; // LD5
      default: LEDX = 5'b00000; // Turn off all LEDs for unknown X-coordinates
      endcase
      if (X_COORD == 4 )begin
          LEDB = 1;
          LEDA = 0;
      end else begin
      LEDA = 1'b0;
      LEDB = 1'b0;
      end
    end
    
    SEND_B:
    begin
     LEDB = 0;
        // LED logic for HIT_A state
        case (X_COORD)
            3'b000: LEDX = 5'b10000; // LD9
            3'b001: LEDX = 5'b01000; // LD8
            3'b010: LEDX = 5'b00100; // LD7
            3'b011: LEDX = 5'b00010; // LD6
            3'b100: LEDX = 5'b00001; // LD5
            default: LEDX = 5'b00000; // Turn off all LEDs for unknown X-coordinates
        endcase
        if (X_COORD == 0 )begin
            LEDA = 1 ;
            LEDB =0;
        end else begin
        LEDA = 0;
        LEDB = 0;
        end
            
    end

    RESP_A: begin
      case(X_COORD) 
      3'b000: LEDX = 5'b10000; // LD9
          3'b001: LEDX = 5'b01000; // LD8
          3'b010: LEDX = 5'b00100; // LD7
          3'b011: LEDX = 5'b00010; // LD6
          3'b100: LEDX = 5'b00001; // LD5
          default: LEDX = 5'b00000; // Turn off all LEDs for unknown X-coordinates
      endcase
      if(X_COORD == 0) begin
        LEDB = 1'b0;
        LEDA = 1'b1;
       end else begin
       LEDA = 1'b0;
       LEDB = 1'b0;
       end
    
    end

    RESP_B: begin
      case(X_COORD) 
      3'b000: LEDX = 5'b10000; // LD9
          3'b001: LEDX = 5'b01000; // LD8
          3'b010: LEDX = 5'b00100; // LD7
          3'b011: LEDX = 5'b00010; // LD6
          3'b100: LEDX = 5'b00001; // LD5
          default: LEDX = 5'b00000; // Turn off all LEDs for unknown X-coordinates
      endcase
      if( X_COORD == 4) begin
        LEDB = 1'b1;
        LEDA = 1'b0;
        end else begin
        LEDA = 1'b0;
        LEDB = 1'b0;
        end
       end

    DISPLAY_SCORE: begin
      LEDX = 5'b11111;
    end

    END_STATE: begin
      
           
        LEDA=0;
        LEDB=0;
        if (timer < 50)begin
            LEDX = 5'b10101;
        end
        else begin
            LEDX = 5'b01010;
        end
      end
       
       
    
    default: begin
        LEDA = 0;
        LEDB = 0;
        LEDX = 5'b00000;
    end
    
  
   endcase 
   end
  
    
endmodule