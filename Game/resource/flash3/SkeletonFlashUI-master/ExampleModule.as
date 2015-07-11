package  {
	
	import flash.display.MovieClip;
	//we have to import mouse events so flash knows what we're talking about
    import flash.events.MouseEvent;
	
	public class ExampleModule extends MovieClip {
		
		
		public function ExampleModule() {
			//we add a listener to this.button1 (I called my button 'button1')
            //this listener listens to the CLICK mouseEvent, and when it observes it, it cals onButtonClicked
            this.myButton.addEventListener(MouseEvent.CLICK, onButtonClicked);
		}
		
		/*this function is new, it is the handler for our listener
         *handlers for mouseEvents always need the event:MouseEvent parameter.
         *the ': void' at the end gives the type of this function, handlers are always voids. */
        private function onButtonClicked(event:MouseEvent) : void {
            trace("click!");
        }
	}
	
}
