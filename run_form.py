# tags: Galileo
# file: realtime_form
# update textbox in realtime
# 2020-08-05
import clr
clr.AddReference('System.Windows.Forms')
from System.Windows.Forms import Clipboard
from System import Action

class RunForm:
    def __init__(self, thread, title, abort_callback):
        self.thread = thread
        self.abort_callback = abort_callback
        self.is_form_shown = False
        self.is_form_closing = False
        self.create_fm(title)

    def printout(self, line, new_line=True):
        """
        append text to the status textbox
        called by an external run_in_thread function
        """
        if self.is_form_closing or not self.is_form_shown:
            return
        if line is None:
            return

        self.txt_status.Invoke( Action[object, bool](self._update_textbox), line, new_line )

    def _update_textbox(self, s, new_line):
        """ append string to textbox, optionally add a new_line character """
        new_s = str(s) + '\r\n' if new_line else str(s)
        self.txt_status.AppendText( new_s )

    def _abort(self):
        """ kill the thread """
        if self.thread is not None and self.thread.IsAlive:
            self.thread.Abort()
            if self.abort_callback is not None:
                self.abort_callback()

    def _on_form_closing(self, sender, e):
        """ if the form is closing, do not update the UI elements in this form anymore """
        self.is_form_closing = True
        self._abort()

    def _on_form_shown(self, sender, e):
        self.is_form_shown = True

    def _on_copy_click(self, sender, e):
        """ if thread is alive do not copy the text """
        if not self.thread.IsAlive:
            Clipboard.SetText(self.txt_status.Text)

    def show_fm(self):
        """ start the thread and then show the form """
        self.thread.Start()
        self.fm.show()

    def create_fm(self, title):
        """ create a form with a textbox and one stop button """
        self.fm = pcpy.Form(title, None, pcpy.Enum.ButtonType.YesNoCancel)
        self.fm.BoxWidth = 500

        # add a run status textbox
        self.txt_status = self.fm.add_textbox('', '')
        self.txt_status.Multiline = True
        self.txt_status.ScrollBars = pcpy.Enum.ScrollBars.Vertical
        self.txt_status.Left = 0
        self.txt_status.Top = 0
        self.txt_status.Height = 300
        self.txt_status.Width = self.fm.Form.Width-18
        self.txt_status.Anchor = pcpy.Enum.Anchor.Left | pcpy.Enum.Anchor.Top | pcpy.Enum.Anchor.Right

        self.fm.CurrentY += 230
        self.fm.Button1.Text = 'Copy'
        self.fm.Button1.Click += self._on_copy_click
        self.fm.Button2.Text = 'Abort'
        self.fm.Button2.Click += lambda sender, e: self._abort()
        self.fm.Button3.Text = 'Close'
        self.fm.Form.Closing += self._on_form_closing
        self.fm.Form.Shown += self._on_form_shown

if __name__ == '<module>':
    import time
    from System.Threading import Thread, ThreadStart
    def run_in_thread():
        try:
            time.sleep(1)
            for ii in range(1000):
                fm.printout(ii)
        except Exception as e:
            print str(e)
            fm.printout(str(e))
            
    fm = RunForm( Thread(ThreadStart(run_in_thread)), 'test run form', None )
    fm.show_fm()