# tags: CloudComputing,RunSWMM,parallel,Galileo
# file: galileo_v1
# 2020-08-11
# updated on: 2021-02-03
# name: Run in Galileo
# description: Perform parallel analysis in the cloud with Galileo (https://galileo.hypernetlabs.io). 
#              Galileo not only lets you easily run many simultaneous analyses in the cloud, 
#              it also securely stores your model input/output history for future reference
#              and collaboration.
import sys, os, traceback
import time, shutil, webbrowser, zipfile
_galileo_path = os.path.join( pcpy.LibFolder, 'env-galileo' )
sys.path.append(_galileo_path)

from System.Threading import Thread, ThreadStart
from System import DateTime, TimeSpan
from galileo_sdk import GalileoSdk, AuthSdk
_help_link = 'https://hypernetlabs.io/galileo/documentation'
_dashboard = "https://galileo.hypernetlabs.io/dashboard"
_image_path = os.path.join( _galileo_path, 'galileo-logo.jpg' )
_pcswmm_audience = "xgSnn1kG97CZdKYoOjEY0YlgoFrc6U3N"  # identify a pcswmm user
_ini_fname = os.path.join( os.path.dirname(os.path.dirname(__file__)), 'galileo.ini' )

from run_form import RunForm

def show_error(lt):
    """ display a generic error form. lt is a list of string """
    fm = pcpy.Form('', None, pcpy.Enum.ButtonType.None)
    fm.HelpLink = _help_link
    wb = fm.add_browser(800, 250)
    wb.DocumentText = ''.join([ "<PRE>%s</PRE>" % line for line in lt ])
    wb.Dock = pcpy.Enum.Dock.Fill
    fm.show()

class GalileoWrapper:
    def __init__(self):
        self.galileo_job = None
        self.galileo_mission = None
        self.station = None
        self.cpu_count = 4 # default number of CPUs
        self.memory_amount = 4096 # default MB of RAM
        
    # first authenticate the user
    def authenticate(self):
        try:        
                                         
            myauth = AuthSdk(client_id=_pcswmm_audience)
            access_token, refresh_token, et = myauth.initialize(_ini_fname)
            self.galileo = GalileoSdk(auth_token=access_token, refresh_token=refresh_token)
            self.galileo.disconnect()
            
            self.set_galileo_parameters()
            
        except Exception as e:
            error = str(e) + '\n' + traceback.format_exc()
            show_error([error, "Something went wrong authenticating your account. Contact Galileo support at support@hypernetlabs.io or visit the Help link for more info."])

    # select the Station to run on and how many CPUs and amount of RAM to request
    def set_galileo_parameters(self):

        try:
            
            # get the station obect to the requested station
            self.stations = self.galileo.stations.list_stations(lz_status="online")

            # make sure a station was found
            if not self.stations:
                raise ValueError("We didn'try find any active compute resources associated with your Galileo account.")

            station_names = [ station.name for station in self.stations ]

            # create form to allow user to select station to deploy to
            self.select_station_form = pcpy.Form("Select your compute resources.", None, pcpy.Enum.ButtonType.YesNoCancel)
            self.select_station_form.HelpLink = _help_link

            # add a web browser
            self.web = self.select_station_form.add_browser(600, 500)
            self.web.Left = 0
            self.web.Top = 0
            self.web.Width = self.select_station_form.Form.Width
            self.web.Anchor = pcpy.Enum.Anchor.Left | pcpy.Enum.Anchor.Right | pcpy.Enum.Anchor.Top
            html_fmt = """
                    <img src='%s'><br>
                    <p>Galileo is and all-in-one productivity tool for simulation engineers.</p>
                    <p>Click the Help button for more info or the Run button to deploy your simulation to the cloud.</p>
                    <p>You will be prompted to sign in through your webbrowser on your first use.</p>
                    <p>Choose the Galileo compute station you wish to deploy to.</p>
                    <p>Note, you must deploy to a windows compatible station.</p>
                    <p>Select compute station to deploy to:</p>
                    <select id="Station">%s</select>
                    <p>Select number of CPUs per scenario:</p>
                    <select id="CPUs">%s</select>
                    <p>Select amount of RAM per scenario (gigabytes):</p>
                    <select id="Memory Amount">%s</select>
                    """
            name_options = ['<option value="{0}">{0}</option>'.format(name) for name in station_names if name.lower() != 'linux']
            cpu_count = ['<option value="{0}">{0}</option>'.format(count) for count in ["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16"]]
            memory_amount = ['<option value="{0}">{0}</option>'.format(amount) for amount in ["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16"]]
            self.web.DocumentText = html_fmt%( _image_path, ''.join(name_options), ''.join(cpu_count), ''.join(memory_amount))

            self.select_station_form.Button1.Text = 'Dashboard...'
            self.select_station_form.Button1.Click += lambda sender, e: webbrowser.open_new_tab(_dashboard)
            self.select_station_form.Button2.Text = 'Run...'
            self.select_station_form.Button2.Click += self.set_parameter_values
            self.select_station_form.CurrentY -= 20
            self.select_station_form.show()

        except Exception as e:
            error = str(e) + '\n' + traceback.format_exc()
            show_error([error, "Contact Galileo support at https://galileo-forum.hypernetlabs.io/c/Issues/17 or visit the Help link for more info."])

    def set_parameter_values(self, sender, e):
        # main function that deploys SWMM simulation and download
        try:
            # get the selected station
            element = self.web.Document.GetElementById('Station')
            selected_station_name = element.GetAttribute('value')
            self.station = [ s for s in self.stations if s.name == selected_station_name ][0]
            
            # get the selected number of CPUs
            element = self.web.Document.GetElementById('CPUs')
            self.cpu_count = int(element.GetAttribute('value'))
            
            # get the selected amount of RAM 
            element = self.web.Document.GetElementById('Memory Amount')
            self.memory_amount = int(element.GetAttribute('value'))*1000

            self.select_station_form.close()

            # make sure a station was found
            if not self.station:
                raise ValueError("Problem with selecting compute station.")

            self.run_scenarios()
                
        except Exception as e:
            error = str(e) + '\n' + traceback.format_exc()
            show_error([error, "Contact Galileo support at support@hypernetlabs.io or visit the Help link for more info."])

    def run_scenarios(self):
        try:
            # set up scenarios and run them in a thread
            thread = Thread( ThreadStart(self.run_in_thread) )
            self.run_fm = RunForm(thread, 'Run in Galileo', self.abort_callback)
            self.run_fm.fm.HelpLink = _dashboard
            self.scenarios = [ RunOneScenario(self.galileo, self.station, inp_file, sn.Version, self.run_fm, self.cpu_count, self.memory_amount) 
                               for inp_file, sn in pcpy.SWMM.Scenarios.iteritems() if sn.ToRun ]
#            self.scenarios = [ RunOneScenario(self.galileo, self.station, pcpy.SWMM.FilePath, pcpy.SWMM.Version, self.run_fm) ]
            self.run_fm.show_fm()

        except Exception as e:
            error = str(e) + '\n' + traceback.format_exc()
            show_error([error, "Contact Galileo support at support@hypernetlabs.io or visit the Help link for more info."])

    def abort_callback(self):
        # if any job is still running, confirm killing
        is_all_done = all( [scen.is_done for scen in self.scenarios] )
        if not is_all_done:
            feedback = pcpy.show_messagebox('Your jobs are running in Galileo, do you want to kill them?', '', pcpy.Enum.IconType.Question, pcpy.Enum.ButtonType.YesNo)
            if feedback == pcpy.Enum.DlgResult.No:
                return
        
        for scen in self.scenarios:
            scen.kill_job()

    def run_in_thread(self):
        # run multiple scenarios in one thread.
        time.sleep(0.5)  # allow the form to be shown so the very first msg can be printout
        scenarios = self.scenarios
        try:
            error = ''
            self.run_fm.printout('------ Submit all jobs to Galileo ------')
            self.run_fm.printout('cpus: ' + str(self.cpu_count) + '   memory_amount (MB): ' + str(self.memory_amount))
            for scen in scenarios:
                error += scen.submit_job()
            if error != '':
                self.run_fm.printout(error)
                return

            # check job run status
            self.run_fm.printout('\r\n------ Check jobs status ------')
            bar = pcpy.ProgressBar('Running scenarios in Galileo: galileo.hypernetlabs.io', len(scenarios)*100)
            while True:
                for scen in scenarios:
                    error += scen.update_status()
                sum_steps = sum([sn.steps for sn in scenarios])
                if sum_steps > 0:
                    bar.update(sum_steps)
                if all([sn.is_done for sn in scenarios]):
                    break
            if error != '':
                self.run_fm.printout(error)
                return

            # perform after done operations
            self.run_fm.printout('\r\n------ Postprocess ------')
            for scen in scenarios:
                error += scen.after_done()
            if error != '':
                self.run_fm.printout(error)
                return
        except Exception as e:     # could be thread aborted, or any other unexpected error
            self.run_fm.printout(e)

class RunOneScenario:
    def __init__(self, galileo, station, inp_file, version, run_fm=None, cpu_count=None, memory_amount=None):
        self.galileo = galileo
        self.station = station
        self.cpu_count = cpu_count
        self.memory_amount = memory_amount
        self.inp_file = inp_file
        self.version = version
        self.run_fm = run_fm
        self.galileo_job = None
        
        self.prj_name = os.path.basename(self.inp_file)[0:-4]     # strip .inp
        self.is_done = False
        self.swmm = pcpy.SWMM if inp_file == pcpy.SWMM.FilePath else pcpy.open_swmm_input(inp_file)

    def submit_job(self):
        try:
            # get the version of the swmm engine
            engine_version = self.version.strip('Open')
            engine_version = self.version.strip('SWMM')
            mission_folder = os.path.dirname(self.inp_file)

            # get run folder
            self.run_folder = os.path.join( mission_folder, 'galileo', self.prj_name )

            # remove folder if existing from a previous run
            if os.path.isdir(self.run_folder):
                shutil.rmtree(self.run_folder)

            # prepare input files
            self.run_fm.printout("Converting Scenario '%s' to EPA format." % self.prj_name)
            input_files, self.output_files = self.swmm.prepare_run(self.run_folder)

            # fill out mission settings and mission type id
            
            # first ensure the mission ID is still valid and the engine version is supported
            mission_type_id = 'f1934063-034a-4eba-adaa-e28bd95f138a'
            
            try:
                settings = self.galileo.missions.get_mission_type_settings_info(mission_type_id)
                if engine_version not in settings["swmmversion"]:
                    self.run_fm.printout("Currently, Engine version %s is not supported.  Terminating run." % engine_version)
                    return str(engine_version)
            except Exception as e:
                self.run_fm.printout("Error retrieving SWMM5 settings from Galileo.")
                return str(e)
            
            # next input mission settings
            mission_settings = {
                "swmmversion": engine_version,
                "filename":self.prj_name,
                "cpu_count": str(self.cpu_count),
                "memory_count": str(self.memory_amount),
            }

            # upload the project
            if self.run_fm:
                self.run_fm.printout("Scenario '%s': uploading input files" % self.prj_name)
            
            try:
                self.galileo_mission = self.galileo.missions.create_and_upload_mission(self.prj_name, self.run_folder, mission_type_id=mission_type_id, settings=mission_settings)
            except Exception as e:
                self.run_fm.printout("Error in Galileo Mission Creation. Try again or contact support at https://galileo-forum.hypernetlabs.io/c/Issues/17")
                return str(e)
                
            if self.run_fm:
                self.run_fm.printout("Scenario '%s': Sending job to station '%s'" % (self.prj_name, self.station.name))
                
            try:
                self.galileo_job = self.galileo.missions.run_job_on_station(self.galileo_mission.mission_id, self.station.stationid, cpu_count=self.cpu_count, memory_amount=self.memory_amount)
            except Exception as e:
                self.run_fm.printout("Error running job on selected Galileo Station. Check your resources in the Galileo dashboard or contact at https://galileo-forum.hypernetlabs.io/c/Issues/17")
                return str(e)

            self.progress1 = 0
            self.time1 = DateTime.Now
            return ''
        except Exception as e:
            self.run_fm.printout("Error in Job RunOneScenario.submit_job.")
            return str(e)

    def update_status(self):
        self.steps = 0
        if self.is_done:
            return ''

        try:
            time.sleep(5)
            job = self.galileo.jobs.list_jobs(jobids=[self.galileo_job.job_id])[0]
            status = job.status
            if status == 'running':
                logs = self.galileo.jobs.request_logs_from_job(self.galileo_job.job_id)
                if logs:
                    lt = logs.split('% complete\r\n')                    
                    # sometimes lt length < 2
                    if len(lt)>=2:                           
                        progress2 = int( float( lt[-2].split()[-1] ) )                        
                        # calculate remaining time in minutes
                        self.steps = progress2 - self.progress1
                        remaining_time = '?'
                        if progress2 > 0:
                            et = (DateTime.Now - self.time1).TotalSeconds / progress2 * (100 - progress2)
                            ts = TimeSpan.FromSeconds(et)
                            remaining_time = '%d days %d hrs %d mins %d secs' % (ts.Days, ts.Hours, ts.Minutes, ts.Seconds)

                        self.progress1 = progress2
                        if self.steps > 0:
                            self.run_fm.printout("Scenario '%s': %d%% complete; Estimated remaining %s" % (self.prj_name, progress2, remaining_time))
            elif status == 'completed':
                self.is_done = True
            elif status in ['error', 'build_error']:
                self.is_done = True
                return 'Error in job run'
            return ''
        except Exception as e:
            self.run_fm.printout("Error in Job RunOneScenario.update_status.")
            return str(e)

    def kill_job(self):
        if not self.is_done and self.galileo_job:
            self.run_fm.printout("Scenario '%s': kill job" % self.prj_name)
            self.galileo.jobs.request_kill_job(self.galileo_job.job_id)

    def after_done(self):
        try:
            # model run is done here, start to download results
            self.run_fm.printout("Scenario '%s': download result zip file" % self.prj_name)
            downloaded_files = self.galileo.jobs.download_job_results(self.galileo_job.job_id,  self.run_folder)

            # extract the zip file. There is always a single downloaded zip file.
            self.run_fm.printout("Scenario '%s': extract result zip file" % self.prj_name)
            zipfile.ZipFile(downloaded_files[0]).extractall(self.run_folder)

            # find the result folder to copy cloud run results to model folder
            for dirname, folder, files in os.walk(self.run_folder, False): # False = search from bottom up
                if self.prj_name+'.out' in files:
                    result_folder = dirname       # get the result folder
                    break
            else:
                return "Scenario '%s': cannot find result folder" % self.prj_name
                
            # copy all other output files e.g. interface file, LID detailed report file to model folder
            self.run_fm.printout("Scenario '%s': copy and refresh output files" % self.prj_name)
            for tp in self.output_files:
                src, dst = tp                     # src = output basename, dst = model specific full path
                if src not in [self.prj_name+'.rpt', self.prj_name+'.out']:
                    shutil.copyfile( os.path.join(result_folder, src), dst )

            # open project. if it is already current project (i.e. pcpy.SWMM.FilePath), do not open it again.
            if self.inp_file != pcpy.SWMM.FilePath:
                pcpy.open_project(self.inp_file)

            self.run_fm.printout("Scenario '%s': Post-Processing" % self.prj_name)
            # move .out and .rpt to model folder and post-process (e.g. read data from rpt file and associate it with shapefiles)
            pcpy.SWMM.refresh_output(result_folder)
            self.run_fm.printout("Scenario '%s': Galileo run completed!" % self.prj_name)
            return ''
        except Exception as e:
            self.run_fm.printout("Error in Job RunOneScenario.after_done.")
            return str(e)


GW = GalileoWrapper()
GW.authenticate()