--------------------------------------------------------------------------------------------------------
                                        D I S C L A I M E R      
--------------------------------------------------------------------------------------------------------
         Please bare in mind that this code was written under time pressure by two students.
                      The code is copywrited by SURFnet and no longer maintained.
Due to requests from other students, this code has been put online for further evaluation and extention.
--------------------------------------------------------------------------------------------------------

        THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY 
        EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
        OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT 
        SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
        INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
        TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR 
        BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON    ANY THEORY OF LIABILITY, WHETHER IN 
        CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN 
        ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH 
        DAMAGE.

--------------------------------------------------------------------------------------------------------

RESEARCH PROJECT FILES:
-----------------------
Please include references to our work when you used this.
Our paper is available: http://rp.delaat.net/2013-2014/p47/report.pdf
  and our presentation: http://rp.delaat.net/2013-2014/p47/presentation.pdf


INSTRUCTIONS:
-------------
Before you start, we recomend to read our paper first, then you'd understand what we mean with things like
profiled netflow data and non-profiled netflow data and how to fill your database.

1) Please make sure the hard coded path (/data/nfsen/plugins/) to this plugin is modified to your own setup.
2) Create a database 'dythraoth.db' according to the 'db-schema.txt' with sqlite3.
   If your setup finally works you can quite easilly change to an other database (like MariaDB or so).
3) Pick a representative week of netflowdata to build your initial dataset.
   - filter out known irregular events (like network disconnects or attacks).
   - do this for your profiled-baseline and for non-profiled-baseline (like all udp and tcp traffic).
   - for every 5 minutes (that is the default at least).
4) Get the values for the spiky traffic and periodic traffic according to the methods we describe in our
   paper from your initial dataset.
5) Load your dataset into the sqlite3 database 
6) Activate the plugin in NFSen
7) Adjust the plugin triggers to the profiles you choose at step 3 and fill in the tresholds from step 4.

You should have a working Proof-of-Concept by now.

The format of the baseline tables:
----------------------------------
  What content of (non-profiled) np_baseline should look like:

    21540_tcp|150000|125000000|120000000000
    21540_udp|90000|30000000|21500000000

  What content of (profiled) p_baseline should look like:

    31115_tcp_80|65000|32000000|41500000000|55000|15000000|1800000000
    31115_udp_53|19000|2000000|500000000|40000|5000000|380000000

* Note that the first 5 numbers of each row have the following structure:
     <day_of_the_week> <hour> <minute>

--------------------------------------------------------------------------------------------------------
                                    Daniel Romao (daniel.romao@os3.nl)
                            Niels van Dijkhuizen (niels.vandijkhuizen@os3.nl)
--------------------------------------------------------------------------------------------------------

