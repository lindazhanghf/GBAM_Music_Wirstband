/*  
    Code based on "State Design Pattern in Java"
    https://sourcemaking.com/design_patterns/state/java/5
*/
import java.lang.String;

public class StateMachine {
  private State[] states     = { new Idle(), new Sprint() }; // 2. states , new C()
  private int     current    = 0;                            // 3. current State
  // private char[]  gestureSequence = new char[10];

  public void changeState(int newState)
  {
    states[newState].onEnter(current);
    current = newState;
  }

  // 5. All client requests are simply delegated to the current state object
  public void onEnter(int oldState) { 
    states[current].onEnter(oldState);   
  }
  public int onExit() { 
    return states[current].onExit();  
  }
  public boolean execute() { 
    return states[current].execute();  
  }
}

// 6. Create a state base class that makes the concrete states interchangeable
 abstract class State {
   public void onEnter(int oldState) { 
     System.out.println( "error" );
   }  // 7. The State base 
   public int onExit() { 
     System.out.println( "error" );
     return 0;
   }  //    class specifies 
   public boolean execute() { 
     System.out.println( "error" );
     return false;
   }  //    default behavior
 }

 class Idle extends State {
   private int nextState;
   public void onEnter(int oldState) { 
     System.out.println( "IDLE + onEnter" );
   }
   public int onExit() { 
     System.out.println( "IDLE + onExit" );
     return nextState;
   }
   public boolean execute() { 
     // R^2 = Rx^2 + Ry^2 + Rz^2 
     println ("                                                                                     vectorR = " + combinedR + "\tabsAverage     = " + absAverage);
     if (combinedR >= SPRINT_BOUND)
     {
       nextState = SPRINT_STATE;
       return true;
     }
     return false;
   }
 }

 class Sprint extends State {
   private int nextState;

   public void onEnter(int oldState) { 
     System.out.println( "Sprint + onEnter" );

     String gesture;
     if (oldState == IDLE_STATE)
     {
      if (absMax == absX)
      {
        if (x >= 0) 
        {
          AudioManipulation.play(xPositive);
          if (oldGesture == RIGHT) return;
          currentGesture = LEFT;
        }
        else 
        {
          if (oldGesture == LEFT) return;
         currentGesture = RIGHT;
        }
      }
      else if (absMax == absY)
      {
        if (y >= 0) 
        {
          AudioManipulation.play(yPositive);
          if (oldGesture == FORWARD) return;
          currentGesture = BACKWARD;
        }
        else
        {
          if (oldGesture == FORWARD) return;
          currentGesture = BACKWARD;
        }
      }
      else
      {
        if (z >= 0) {
          AudioManipulation.play(zPositive);
          if (oldGesture == DOWN) return;
          currentGesture = UP;
        }
        else
        {
          if (oldGesture == UP) return;
          currentGesture = DOWN;
        }
      }

      if (currentGesture != oldGesture) {
        gestureBuffer += currentGesture;
        oldGesture = currentGesture;
      }
    } // old: idle_state
   }

   public int onExit() { 
     System.out.println( "Sprint + onExit" );
     return nextState;
   }

   public boolean execute() { 
     // println ("Sprint: vectorR = " + combinedR + "\tabsAverage     = " + absAverage);
     if (combinedR < SPRINT_BOUND)
     {
      nextState = IDLE_STATE;
      return true;
     }
     return false;
   }


 }
