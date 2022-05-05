package taurusbdd; 

import static org.junit.Assert.assertEquals;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileWriter;   // Import the FileWriter class
import java.io.IOException;  // Import the IOException class to handle errors
import java.io.InputStreamReader;
// import dataprovider.ConfigFileReader;
import io.cucumber.java.en.And;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;




public class StepDef { 

String urlvariable="";
String concurrentvariable="";
String responsevariable="";
String TaurusFile = "";
String cloudstring = "";
String loadstring = "";
String processcmd = "";
String bzmtoken;
String parametervariable;
// ConfigFileReader configFileReader;
String testexecutionname = "";
String durationvariable = "";
String rampupvariable = "";
String datagenvariable;
String jmxvariable;



   @Given("^API Query ([^\"]*)$") 
   public void URL(String url){
	   urlvariable = url ;
   } 
   

   @And("^parameter is ([^\"]*)$") 
   public void parameter(String parameter){
	   parametervariable = parameter ;
   } 
   
   
   
   @Given("^API Data Query ([^\"]*)$") 
   public void DataFrame(String url) {
	   urlvariable = url ;
   } 

   @Given("^load test called ([^\"]*)$") 
   public void jmxfile(String jmx) {
	   jmxvariable = jmx ;
   } 
   

   @And("Report is generated from the Cloud$")
   public void cloudsetting(){
	   cloudstring = "- module: blazemeter";
   }
  
//   @And("Load is generated from the Cloud$")
//   public void loadsettings(){
//	   configFileReader= new ConfigFileReader();
//	   bzmtoken = configFileReader.getbzmtoken();
//	   loadstring = ", \"-o modules.blazemeter.token="+bzmtoken+" -cloud\"";
//   }

   @And("^the test executes for ([^\"]*) minutes$")
   public void specification(String duration){
	   durationvariable = duration ;
	   System.out.println("Duration  = " + duration );
   }

   @And("^has a ramp up time of ([^\"]*) minutes$")
   public void rampup(String rampup){
	   rampupvariable = rampup ;
   } 
   
   @And("^([^\"]*) users connect$")
   public void Concurrency(String concurrency){
	   concurrentvariable = concurrency ;
   }
   
   @When("^Response time is less than ([^\"]*)$") 
   public void setresponse(String response) throws IOException { 
	   responsevariable = response ;
   }

   @Then("^Response is ([^\"]*)$") 
   public void responsestatus(String status) throws IOException { 

	   if (durationvariable != null  ) {
		   durationvariable = "1";
		 }
	   if (rampupvariable != null ) {
		   rampupvariable = "1";
		 }
	   
	   if (jmxvariable == null ) {
	   
	   try {
	   testexecutionname = System.currentTimeMillis()+".yaml";
	   FileWriter myWriter = new FileWriter(testexecutionname);
       TaurusFile = ("execution:\r\n"
       		+ "  concurrency: "+concurrentvariable+"\r\n"
       		+ "  hold-for: "+durationvariable+"m\r\n"
       		+ "  ramp-up: "+rampupvariable+"s\r\n"
       		+ "  scenario: Thread Group\r\n"
       		+ "\r\n"
       		+ "scenarios:\r\n"
       		+ "  Thread Group:\r\n"
       		+ "    requests:\r\n"
       		+ "    - label: perftest\r\n"
       		+ "      method: GET\r\n"
       		+ "      url: "+urlvariable+parametervariable+"\r\n"
       		+ "reporting:\r\n"
       		+ "- module: final-stats\r\n"
       		+ "  summary: true  # overall samples count and percent of failures\r\n"
       		+ "  module: junit-xml  # Create Junit report\r\n"
       		+ "  percentiles: false  # display average times and percentiles\r\n"
       		+ "  summary-labels: false # provides list of sample labels, status, percentage of completed, avg time and errors\r\n"
       		+ "  failed-labels: false  # provides list of sample labels with failures\r\n"
       		+ "  test-duration: false  # provides test duration\r\n"
       		+ cloudstring+"\r\n"
       		+ "- module: passfail\r\n"
       		+ "  criteria:\r\n"
       		+ "    Response Time Does not match requirements : avg-rt >"+responsevariable+" for 5s, stop as failed\r\n");
       myWriter.write(TaurusFile);
       myWriter.close();
       System.out.println("Performance Test of " +concurrentvariable+ " users for "+durationvariable+" minutes.  URL = "+ urlvariable +  " and a response time of "+ responsevariable);
     } catch (IOException e) {
       System.out.println("An error occurred.");

       e.printStackTrace();
     }
	     ProcessBuilder processBuilder = new ProcessBuilder();

	 //      System.out.println("Load String = " + loadstring);
	       
	        processBuilder.command("bzt.exe", testexecutionname + loadstring );

	        try {

	            Process process = processBuilder.start();

	            BufferedReader reader =
	                    new BufferedReader(new InputStreamReader(process.getInputStream()));

	            String line;
	            while ((line = reader.readLine()) != null) {
	                System.out.println(line);
	            }

	            int exitCode = process.waitFor();
	            System.out.println("\nExited with error code : " + exitCode);
	            File myObj = new File(testexecutionname); 
	            if (myObj.delete()) { 
	              System.out.println("Deleted the file: " + myObj.getName());
	            } else {
	              System.out.println("Failed to delete the file.");
	            } 
	            assertEquals(0, exitCode);

	        } catch (IOException e) {
	            e.printStackTrace();
	        } catch (InterruptedException e) {
	            e.printStackTrace();
	        }
	   }  
	   else {
		   try {
			   testexecutionname = System.currentTimeMillis()+".yaml";
			   FileWriter myWriter = new FileWriter(testexecutionname);
		       TaurusFile = ("execution:\r\n"
		       		+ "  concurrency: "+concurrentvariable+"\r\n"
		       		+ "  hold-for: "+durationvariable+"m\r\n"
		       		+ "  ramp-up: "+rampupvariable+"s\r\n"
		       		+ "  scenario: JMeter Test\r\n"
		       		+ "\r\n"
		       		+ "scenarios:\r\n"
		       		+ "  JMeter Test:\r\n"
		       		+ "       script: C:\\JMXTests\\"+jmxvariable +".jmx\r\n"
		       		+ "reporting:\r\n"
		       		+ "- module: final-stats\r\n"
		       		+ "  summary: true  # overall samples count and percent of failures\r\n"
		       		+ "  module: junit-xml  # Create Junit report\r\n"
		       		+ "  percentiles: false  # display average times and percentiles\r\n"
		       		+ "  summary-labels: false # provides list of sample labels, status, percentage of completed, avg time and errors\r\n"
		       		+ "  failed-labels: false  # provides list of sample labels with failures\r\n"
		       		+ "  test-duration: false  # provides test duration\r\n"
		       		+ "- module: passfail\r\n"
		       		+ "  criteria:\r\n"
		       		+ "    - avg-rt >"+responsevariable+", stop as failed\r\n"
		       		+ cloudstring+"\r\n"		       		);
		       myWriter.write(TaurusFile);
		       myWriter.close();
		       System.out.println("Performance Test of " +concurrentvariable+ " users for "+durationvariable+" minutes.  JMeter Test = "+ jmxvariable +  " and a response time of "+ responsevariable);
		     } catch (IOException e) {
		       System.out.println("An error occurred.");

		       e.printStackTrace();
		     }
			     ProcessBuilder processBuilder = new ProcessBuilder();

			 //      System.out.println("Load String = " + loadstring);
			       
			        processBuilder.command("bzt.exe", testexecutionname + loadstring );

			        try {

			            Process process = processBuilder.start();

			            BufferedReader reader =
			                    new BufferedReader(new InputStreamReader(process.getInputStream()));

			            String line;
			            while ((line = reader.readLine()) != null) {
			                System.out.println(line);
			            }

			            int exitCode = process.waitFor();
			            System.out.println("\nExited with error code : " + exitCode);
			            File myObj = new File(testexecutionname); 
			            if (myObj.delete()) { 
			              System.out.println("Deleted the file: " + myObj.getName());
			            } else {
			              System.out.println("Failed to delete the file.");
			            } 
			            assertEquals(0, exitCode);

			        } catch (IOException e) {
			            e.printStackTrace();
			        } catch (InterruptedException e) {
			            e.printStackTrace();
			        }
			   }  
	   }
	 }
