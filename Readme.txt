
#########################################################################
####### Installation guidelines for HERMES Moving Object Database #######
#########################################################################


PREREQUISITES

- The following steps assume that an Oracle Database server has already been installed. In order for all the modules of HERMES to be functional,
the user should install a version later than 11gR1 v.11.1.0.6 or 11gR2 of the Enterprise Edition. 
Below, by %ORACLEHOME% we mean the path where the Oracle Server has been installed.
For instance, if you have installed Oracle Server in 'D:\' as a user named 'npelekis' then %ORACLEHOME%='D:\app\npelekis\product\11.2.0\dbhome_1'

STEPS

1. INSTALLATION[mandatory]

UNZIP the zipped file you downloaded to some folder in your hard disk. The UNZIP creates a folder named HERMES. The path of this folder is referred below as %HERMESHOME%.
For instance, if you unzip the .rar file you downloaded in 'C:\' then %HERMESHOME%='C:\HERMES'
In %HERMESHOME% there are various sub-folders that either contain necessary scripts or are required for IO processes.
Start by executing installHERMES.bat(double click). Installation begins. You are asked for the SID of your Oracle database and for the password of SYSTEM user. Users named "TAU_TLL" and "HERMES" are created (passwords as their names). 
Every time an external action is required by you the script stops and provides information of what to do. For example you need to copy a library file (dll) to a specific location on your machine and then to login as a user to database and inform database about that location. The script describes those steps in detail.

DEVELOPER TIP

If you do not want to drop and recreate those two schemas as the script does, then you can refer to Realese Notes file and apply all changes mentioned there to your schema. All schema objects are on folder HERMES\CreateDB\allobjects. From there you can take the object that has changed and recompile it.

##################################################################################################################################

2. HERMES LOADER[optional]

You may load data (trajectories sets) when the script tells you or you may continue execution and load data later.

There are three different loading procedures for loading data into HERMES MOD engine, which use two different formats for RAW data.
We exemplify their usage by providing scripts for loading the MILANO dataset.

MIND that after loading data you must insert a row into parameters table to link the dataset with an SRID and also insert another row into history_table table to access the dataset from the GUI tool. After loading data you can issue the BUILD_TBTREE.sql to create o TBTREE index on that data.

##################################################################################################################################

You can do this through the HERMES GUI software also.

2.1. The first approach assumes that the user has data in a format in a CSV file like the following example, which in each line of the file there are the
subsequent 10 values that describe the information of a particular space-time recording:

USERID ,
TRAJECTORYID ,
X ,
Y ,
YEAR ,
MONTH ,
DAY ,
HOUR ,
MINUTE ,
SECOND

EXAMPLE: A trajectory with 3 recordings, i.e. 2 (three-dimensional) segments
...
1575|38|1511855,64808791|5033093,75822316|2008|4|4|17|7|0
1575|38|1512650,75432479|5032583,65401271|2008|4|4|17|13|5
1575|38|1512536,53550243|5032551,28054155|2008|4|4|17|14|57
...

In the above example columns are seperated by the character '|'

STEPS
- First two tables (one relational, and one object-relational) using schemas exactly like the following 
are created by default from the db creation script above:

'%HERMESHOME%\CreateDB\allobjects\milano_raw.sql'
'%HERMESHOME%\CreateDB\allobjects\milano_mpoints.sql'

- Create a CONTROL file and put data inside like the following: 

%HERMESHOME%\data\MILANO\MILANO_RAW_TRAJECTORIES_CL.ctl--referencing milano_raw table inside

- Load data into the relational table. To do this, first locate in command prompt the Directoty where the CONTROL file exists, and run the SQLLoader utility of Oracle with the following command:

SQLLDR USERID=HERMES/HERMES CONTROL=MILANO_RAW_TRAJECTORIES_CL.ctl (MIND THE DELIMETERS)

- Run the following procedure

Run hermes.raw_trajectories_loader.bulkload_raw_trajectories(...)
giving as parameter the srid for the data the raw source table name and the target table name.

- Finally (OPTIONAL as you already have the target table from above), load the constructed trajectories to the "mpoints" table which the tbtree index will be defined on. For the Milano dataset utilized in our example execute the following command.

INSERT into mpoints select * from MILANO_MPOINTS;

==================================================================================================================================
NEEDS TO BE CHECKED
2.2. The second approach assumes that RAW data are stored in a text file (without file extension e.g. MILANO_CL and NOT MILANO_CL.txt), in the IO directory.
So, copy your data file in the IO folder.

Each line of the input file contains the whole trajectory of a moving object, i.e.:
<ID> < k = n.snapshots > < t1 > < x1 > < y1 > . . .< tk > < xk > < yk >
In particular, times t1, . . . ..., tk have to be ordered (ascending order), while values should be comma separated.
EXAMPLE:
...
0 4 0.0 9933.0 8551.46 2.67 9944.38 8437.65 5.33 9963.98 8324.4 8.0 9961.1 8209.65
...

STEPS
- Run the following script to load data to an Object-Relational table (which is ASSUMMED THAT EXISTS, as previously) and which has  only one parameter, the name of the INPUT file.
Note/Change line 313 (i.e. INSERT statement) in LoadFromFile_ID_N_t_x_y FUNCTION if you wish to load your data to some other table.

Run hermes.raw_trajectories_loader.LoadFromFile_ID_N_t_x_y.sql

The user can perform the opposite operation (transform HERME's Moving_Point to trajectories with the above format and output it to a TXT file).
The following script does so for the Milano dataset

Run hermes.raw_trajectories_loader.MovingPointTable2TXT.sql

Similarly trajectories can be transformed to Well Known Text (WKT) format

Run hermes.visualizer.MovingPointTable2WKT.sql

==================================================================================================================================
NEEDS TO BE CHECKED
2.3. The third approach assumes that you already have created an Oracle Network.
For instance, given that you have created the 'ATHPIR' network (i.e. part of the network of Athens & Piraeus cities)
the only thing that one needs to do is to install an appropriate procedure and run it by giving as parameter the number of trajectories to be created.
The created trajectories are created randomly moving on the network

More specifically:

- To install ATHPIR network follow the guidelines in "ATHPIR_Oracle_Spatial_Network_2010.ppt"
- Run NDM_RANDOM_TRAJ_GENERATOR.sql
- Run hermes.ndm_random_traj_generator.sql (creates 10 random trajectories)

##################################################################################################################################

3. USING TDW[optional]

You can do this through the HERMES GUI software also (as Default TDW).

To use the TDW infrastructure two tables must already exists, %someTable%_raw and %someTable%_mpoints 
that holds the raw data loaded and the transformed data to moving points after the loading phase:

1 - define a spatio-temporal grid by invoking the procedures SPLITSPACE and SPLITTIME of the TDW package
(in any case the user should define the step that corresponds to grid's granularity)

For instance, the execution of the following script partitions the spatio-temporal space in cells with 1000 meters length in X and Y axes and with 100 seconds duration

DECLARE

BEGIN
    hermes.tdw.splitspace(1000,1000); --it assumes existance of tables MILANO_RAW and MILANO_MPOINTS
    hermes.tdw.splittime(100);  --or use the overloaded methods e.g. hermes.tdw.splittime(100, 'ATHENS') if you loaded your data in tables with names ATHENS_RAW and ATHENS_MPOINTS
END;

2 - Invoke the appropriate Extract-Transform-Load (ETL) procedure depending on whether you have built a TBtree on MPOINTS or not.

Run tdw.feed_tdw_mbr_BulkFeed (when NO TB-tree has been built)

OR

Run tdw.feed_tdw_tbtree_BulkFeed (when Tb-tree has been built) (RECOMMENDED for more efficiency when the granularity is small)

3 - Execute procedure TDW.CALCULATEAUXILIARY_CL so auxiliary measures are updated.

All above methods are overloaded so they can be executed in any TDW scheme (any table names prefixes) you create with method TDW.createTDW(prefix)

Default (MILANO) TDW example:
BEGIN
    hermes.tdw.splitspace(5000,5000); --10000
    hermes.tdw.splittime(3600);         --1000
    tdw.feed_tdw_mbr_bulkfeed;
    tdw.calculateauxiliary_cl;
END;

=========================================================================

Copyright Notice

=========================================================================


The HERMES software is copyrighted by the Regents of the University of
Piraeus. It can be freely used for educational and research purposes 
by non-profit institutions and US government agencies only. Other 
organizations are allowed to use HERMES only for evaluation purposes,
and any further uses will require prior approval. The software 
may not be sold or redistributed without prior approval. One may 
make copies of the software for their use provided that the copies, 
are not sold or distributed, are used under the same terms and 
conditions. 

As unestablished research software, this code is provided on an 
``as is'' basis without warranty of any kind, either expressed or 
implied. The downloading, or executing any part of this software 
constitutes an implicit agreement to these terms. These terms and 
conditions are subject to change at any time without prior notice.

#########################################################################

Contact Information

#########################################################################

If you have any questions or problems with HERMES please contact the author
at npelekis@unipi.gr.

-------------
Nikos Pelekis
19/8/2010, 22/05/2012


