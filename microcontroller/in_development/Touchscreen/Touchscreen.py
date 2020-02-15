from kivy.app import App
from kivy.uix.widget import Widget
from kivy.clock import Clock
from kivy.properties import NumericProperty, ObjectProperty
from kivy.uix.dropdown import DropDown
from kivy.uix.button import Button
from kivy.base import runTouchApp


class ScreenMain(Widget):
    
    def update(self, dt):
        #self.d_humidity.hum += 1
        pass
    
    pass

class ScreenApp(App):
    def build(self):
        screen = ScreenMain()
        Clock.schedule_interval(screen.update, 1.0/100.0)
        return screen
    
class ScreenBluetooth(Widget):
    pass

class ScreenLogging(Widget):
    pass

class ScreenDiagnostic(Widget):
    pass


class ScreenTemp(Widget):
    temp = NumericProperty(0)
    pass

class ScreenHum(Widget):
    hum = NumericProperty(0)
    pass

class ScreenVolt(Widget):
    volt = NumericProperty(0)
    pass

class ScreenCurr(Widget):
    curr = NumericProperty(0)
    pass

#Dropdown menus
humDrop = DropDown()
tempDrop = DropDown()
voltDrop = DropDown()
currDrop = DropDown()

#Humidity


#Temperature
tbtn1 = Button(text = "Celcius", height = 44)
tbtn1.bind(on_release = lambda tbtn1: tempDrop.select(tbtn1.text))
tempDrop.add_wdiget(tbtn1)

#Voltage


#Current



if __name__ == '__main__':
    ScreenApp().run()
    
    
    
    
    
    
    