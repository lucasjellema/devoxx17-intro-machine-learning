-- against table J1_SESSIONS

  DECLARE
    l_policy     VARCHAR2(30):='session_class_policy';
    l_preference VARCHAR2(30):='session_nb_lexer';
  BEGIN
    BEGIN
      ctx_ddl.drop_policy(l_policy);
    EXCEPTION
    WHEN OTHERS THEN
      NULL;
    END;
    BEGIN
      ctx_ddl.drop_preference(l_preference);
    EXCEPTION
    WHEN OTHERS THEN
      NULL;
    END;
    ctx_ddl.create_preference(l_preference, 'BASIC_LEXER');
    ctx_ddl.create_policy(l_policy, lexer => l_preference);
  END;


CREATE TABLE session_class_nb_settings
  (
    setting_name  VARCHAR2(30),
    setting_value VARCHAR2(4000)
  );


DECLARE
  l_policy     VARCHAR2(30):='session_class_policy';
BEGIN
  -- Populate settings table
  INSERT
  INTO session_class_nb_settings VALUES
    (
      dbms_data_mining.algo_name,
      dbms_data_mining.algo_naive_bayes
    );
  INSERT
  INTO session_class_nb_settings VALUES
    (
      dbms_data_mining.prep_auto,
      dbms_data_mining.prep_auto_on
    );
  INSERT
  INTO session_class_nb_settings VALUES
    (
      dbms_data_mining.odms_text_policy_name,
      l_policy
    ); 
/*  INSERT
  INTO plsql_nb_settings VALUES --
    (
      dbms_data_mining.NABS_PAIRWISE_THRESHOLD,
      0.01
    ); --
  INSERT
  INTO plsql_nb_settings VALUES --
    (
      dbms_data_mining.NABS_SINGLETON_THRESHOLD,
      0.01
    );
    */
  COMMIT;
END;


    DECLARE
    xformlist dbms_data_mining_transform.TRANSFORM_LIST;
    BEGIN
    BEGIN
        DBMS_DATA_MINING.DROP_MODEL('SESSION_CLASS_NB');
    EXCEPTION
    WHEN OTHERS THEN
        NULL;
    END;
    dbms_data_mining_transform.SET_TRANSFORM( xformlist, 'abstract', NULL, 'abstract', NULL, 'TEXT(TOKEN_TYPE:NORMAL)');
    DBMS_DATA_MINING.CREATE_MODEL( model_name => 'SESSION_CLASS_NB'
    , mining_function => dbms_data_mining.classification
    , data_table_name => 'J1_SESSIONS'
    , case_id_column_name => 'session_title'
    , target_column_name => 'session_track'
    , settings_table_name => 'session_class_nb_settings'
    , xform_list => xformlist);
    END;
    /


select distinct session_track 
from j1_sessions

Developer Community Day: Developer Relations
Java Development Tools
Java Community
Core Java Platform
Developer Community Day: NetBeans
Java Clients and User Interfaces
Java and Devices
Developer Community Day: User Groups
Emerging Languages
Java, Cloud, and Server-Side Development
Developer Community Day: Community


Test model 

SELECT session_title
,      PREDICTION(SESSION_CLASS_NB USING *) AS predicted_target
,      abstract
FROM   J1_SESSIONS
where  track is null
  
select *
from (SELECT session_title
,      PREDICTION(SESSION_CLASS_NB USING *) AS predicted_target
,      session_track
,      abstract
FROM   J1_SESSIONS
)
where predicted_target != session_track


Against abstracts from Devoxx Marco:


with sessions_to_judge as
( select 'Living documentation with Asciidoctor and Gradle' session_title
  ,      'It is common sense that good documentation is essential to the success of projects, especially for those running mid and long term. But tools currently used to create and maintain documentation like OfficeSuites and Wikis practically promote the divagation between the system and whats documented. This session shows how to use state of art tools like AsciiDoctor, Gradle and version control to create and maintain documentation while easing the burden of documentation maintenance by implementing a practical workflow with your daily used toolset. This establishes also the collaborative focus of project work on documentation aspects. Having documentation tamed like this, the next step is to bring techniques like "Specification by Example" and "Living Documentaion" to your project and leverage from not just doing things right (and validated) but also making sure to do the right things (as specified).' abstract
  from dual
  UNION ALL
  select 'Winning Hearts and Minds with User Experience' session_title
  ,      'Not too long ago, applications could focus on feature functionality alone and be successful. Today, they must also be beautiful, responsive, and intuitive. In other words, applications must be designed for user experience (UX) because when they are, users are far more productive, more forgiving, and generally happier. Who doesnt want that? In this session learn about the psychology behind what makes a great UX, discuss the key principles of good design, and learn how to apply them to your own projects. Examples are from Oracle Application Express, but these principles are valid for any technology or platform. Together, we can make user experience a priority, and by doing so, win the hearts and minds of our users. We will use Oracle JET as well as ADF and some mobile devices and Java' abstract
  from dual
  UNION ALL
  select 'Building Cloud Native Progressive Web Apps' session_title
  ,      'In this session, you’ll learn how to build microservices with Spring, deploy them to the cloud and expose their functionality with a progressive web application that can run offline. You’ll learn how to “build to fail” and create a quality, resilient application. Live coding will show how to use Kotlin, Spring Boot, Spring Cloud, Cloud Foundry, IntelliJ IDEA, Angular, and Progressive Web Apps.' abstract
  from dual
  UNION ALL
  select 'Serverless Architectures' session_title
  ,      'Serverless architecture (or function as a service, FaaS) is THE new trend in the cloud. It’s an often used, highly efficient, well established technology and common building block in all major public clouds. This session is about technology and clouds first of all. You don’t have to be an expert to attend it. It brings you up to date and gives an overview of serverless computing technology on different cloud provider platforms.We will focus on AWS and talk about the technical details of FaaS, explain what makes it so special, delineate it from seemingly similar technologies already offered by AWS Beanstalk or Oracle such as Oracle Application Container Cloud (ACCS) service.Once we covered the basics we will look into more advanced topics such as security, scalability, debugging and pricing. Finally, we discuss if FaaS will become the de-facto runtime environment for microservices.The talk concludes with a live demo using FaaS based on the brand new open source serverless Fn Project.' abstract
  from dual
)
SELECT session_title
,      PREDICTION(SESSION_CLASS_NB USING *) AS predicted_target
,      abstract
FROM   sessions_to_judge


as SYS:

grant execute on ctx_ddl to c##devoxx

GRANT create mining model TO c##devoxx;