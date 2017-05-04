       identification division.
       program-id. snake.

       data division.
       working-storage section.
      *>Constant ASCII codes
       01 ASCII-W pic 9(1) usage is comp value 119.
       01 ASCII-A pic 9(1) usage is comp value 97.
       01 ASCII-S pic 9(1) usage is comp value 115.
       01 ASCII-D pic 9(1) usage is comp value 100.
       01 ASCII-Q pic 9(1) usage is comp value 113.
      *>Constant codes for cur-direction
       01 DIR-UP pic 9(1) value 1.
       01 DIR-LEFT pic 9(1) value 2.
       01 DIR-DOWN pic 9(1) value 3.
       01 DIR-RIGHT pic 9(1) value 4.
      *>Constant visual symbols
       01 VIS-SNAKE pic x(1) value "o".
       01 VIS-FOOD pic x(1) value "#".
       01 VIS-BLANK pic x(1) value ".".

       01 input-char pic 9(8) usage is comp.
       01 old-direction pic 9(1) value 3.
       01 cur-direction pic 9(1) value 3.

      *> The snake, board is 10x10, max-length is 100
       01 snake.
             05 snake-part occurs 100 times indexed by snake-index.
             10 snake-x pic 9(2).
             10 snake-y pic 9(2).
       01 snake-len pic 9(3) usage is comp value 1.
       01 next-snake-pos.
             10 next-snake-x pic 9(2).
             10 next-snake-y pic 9(2).

       01 food.
             05 food-x pic 9(2).
             05 food-y pic 9(2).

       01 game-screen.
             05 screen-row occurs 10 times.
             10 screen-pixel pic x(1) value '.' occurs 10 times.
      *> Puts a newline after each row for printing
             10 screen-nl pic 9(1) usage is comp value 10.
      *> Puts a null after at the end for printing
             05 screen-null pic 9(1) usage is comp value 0.

       01 create-more-food pic 9(1) value 1.
       01 snake-grew pic 9(1) value 1.

      *> To limit FPS
       01 ms-count pic 9(3) usage is comp.
       01 ms-move-time pic 9(3) usage is comp value 350.

       procedure division.
       main-para.
           call "initscr".
           call "noecho".
           call "timeout" using by value 0.

           move VIS-SNAKE to screen-pixel(1, 1).
           move 1 to snake-x(1), snake-y(1).
           perform game-loop with test after until input-char = ASCII-Q.

           perform game-over.

       game-over.
           call "endwin".
           display "Game over man, GAME OVER! Score: "snake-len.
           stop run.

       game-loop.
           if create-more-food = 1 then
                 perform create-food
           end-if.

           call "clear".
           perform draw.
           perform input-para.

           if ms-count > ms-move-time then
                 perform handle-move
                 move 0 to ms-count
           end-if.

           call "usleep" using by value 1.
           add 1 to ms-count.

       input-para.
           call "getch" returning input-char.

           evaluate true
               when input-char = ASCII-W and not old-direction =
                     DIR-DOWN
                   move DIR-UP to cur-direction
               when input-char = ASCII-A and not old-direction =
                     DIR-RIGHT
                   move DIR-LEFT to cur-direction
               when input-char = ASCII-S and not old-direction =
                     DIR-UP
                   move DIR-DOWN to cur-direction
               when input-char = ASCII-D and not old-direction =
                     DIR-LEFT
                   move DIR-RIGHT to cur-direction
           end-evaluate.

       create-food.
           perform generate-food-location until screen-pixel(food-y,
           food-x) = VIS-BLANK.
           move VIS-FOOD to screen-pixel(food-y, food-x).
           move 0 to create-more-food.

       generate-food-location.
      *> Random isn't seeded
           compute food-x = function random * 10 + 1.
           compute food-y = function random * 10 + 1.

       draw.
           call "printw" using game-screen.
           call "printw" using "Score: %d", by value snake-len.

       shift-snake.
           compute snake-x(snake-index) = snake-x(snake-index - 1).
           compute snake-y(snake-index) = snake-y(snake-index - 1).

       handle-move.
           perform get-next-pos.

           move 0 to snake-grew.

           if screen-pixel(next-snake-y, next-snake-x) = "o" then
                 perform game-over
           else
                 if next-snake-x = food-x and next-snake-y = food-y then
                       add 1 to snake-len
                       compute snake-x(snake-len) = snake-x(
                             snake-len - 1)
                       compute snake-y(snake-len) = snake-y(
                             snake-len - 1)
                       move 1 to create-more-food
                       move 1 to snake-grew
                  end-if
           end-if.

           move VIS-SNAKE to screen-pixel(next-snake-y, next-snake-x).
           if snake-grew = 0 then
                 move VIS-BLANK to screen-pixel(snake-y(snake-len),
                       snake-x(snake-len))
           end-if.

           perform shift-snake varying snake-index from snake-len by -1
                 until snake-index = 1.
      
           move next-snake-x to snake-x(1).
           move next-snake-y to snake-y(1).
           
           move cur-direction to old-direction.

       get-next-pos.
           move snake-x(1) to next-snake-x.
           move snake-y(1) to next-snake-y.
           evaluate true
               when cur-direction = DIR-UP
                   perform get-next-pos-up
               when cur-direction = DIR-LEFT
                   perform get-next-pos-left
               when cur-direction = DIR-DOWN
                   perform get-next-pos-down
               when cur-direction = DIR-RIGHT
                   perform get-next-pos-right
           end-evaluate.

       get-next-pos-up.
           if snake-y(1) = 1 then
                 move 10 to next-snake-y
           else
                 subtract 1 from snake-y(1) giving next-snake-y
           end-if.

       get-next-pos-left.
           if snake-x(1) = 1 then
                 move 10 to next-snake-x
           else
                 subtract 1 from snake-x(1) giving next-snake-x
           end-if.

       get-next-pos-down.
           if snake-y(1) = 10 then
                 move 1 to next-snake-y
           else
                 add 1 to snake-y(1) giving next-snake-y
           end-if.

       get-next-pos-right.
           if snake-x(1) = 10 then
                 move 1 to next-snake-x
           else
                 add 1 to snake-x(1) giving next-snake-x
           end-if.
