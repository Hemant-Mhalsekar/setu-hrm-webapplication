PGDMP     )                    {            setuhrmwebapp    15.1    15.1 X    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    16398    setuhrmwebapp    DATABASE     �   CREATE DATABASE setuhrmwebapp WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'English_United States.1252';
    DROP DATABASE setuhrmwebapp;
                postgres    false            �            1255    16472 �   login_save(character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.login_save(p_fname character varying, p_lname character varying, p_email character varying, p_password character varying, p_pan character varying, p_orgname character varying, p_orgaddress character varying, p_host character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
	org_id character varying;
    emp_id character varying;    
BEGIN

    SELECT 'ORG' || lpad(CAST(COALESCE(max(substring(orgreg_id, 4)::integer), 0) + 1 AS TEXT), 5, '0') INTO org_id FROM orgreg_tbl;
	SELECT 'EMP' || lpad(CAST(COALESCE(max(substring(empreg_id, 4)::integer), 0) + 1 AS TEXT), 5, '0') INTO emp_id FROM empreg_tbl;
	
    INSERT INTO orgreg_tbl (orgreg_id, orgreg_name, orgreg_address, orgreg_pan,orgreg_regdate, orgreg_activeyn, system_date, system_user, system_host)
    VALUES (org_id, p_orgname, p_orgaddress, p_pan,current_timestamp, 'Y', current_timestamp, p_email, p_host);
    
    INSERT INTO empreg_tbl (empreg_id, empreg_fname, empreg_lname, empreg_email, empreg_password, empreg_usertype, empreg_activeyn, system_date, system_user, system_host, orgreg_id)
    VALUES (emp_id, p_fname, p_lname, p_email, p_password, 'A', 'Y', current_timestamp, emp_id, p_host, org_id);

	RETURN 'Your account has been created';
END;
$$;
    DROP FUNCTION public.login_save(p_fname character varying, p_lname character varying, p_email character varying, p_password character varying, p_pan character varying, p_orgname character varying, p_orgaddress character varying, p_host character varying);
       public          postgres    false            �            1255    24660 4   login_validate(character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.login_validate(emailid character varying, pass character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
  user_id text;
BEGIN
  SELECT empreg_id::text INTO user_id
  FROM public.empreg_tbl
  WHERE empreg_email = emailid AND pass = empreg_password;
  
  IF user_id IS NOT NULL THEN
    RETURN 'Login successful';
  ELSE
    RETURN 'Incorrect email or password';
  END IF;
END;
$$;
 X   DROP FUNCTION public.login_validate(emailid character varying, pass character varying);
       public          postgres    false            �            1255    16449 A   otp_save(character varying, character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.otp_save(p_emailid character varying, p_otpno character varying, p_host character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE 
    v_srno integer;
BEGIN
    SELECT nextval('otp_srno_seq') INTO v_srno;

    UPDATE otp_tbl 
    SET otp_latestyn = 'N'
    WHERE lower(otp_emailid) = lower(p_emailid);

    INSERT INTO public.otp_tbl(
        otp_emailid, otp_srno, otp_no, otp_gendatetime, otp_usedtime, otp_activeyn, otp_latestyn, system_date, system_user, system_host)
    VALUES (p_emailid, v_srno, p_otpno::integer, current_timestamp, '01-jan-1900', 'Y', 'Y', current_timestamp, p_emailid, p_host);

    RETURN p_otpno;
END;
$$;
 q   DROP FUNCTION public.otp_save(p_emailid character varying, p_otpno character varying, p_host character varying);
       public          postgres    false            �            1255    16424 (   otp_validate(character varying, integer)    FUNCTION     8  CREATE FUNCTION public.otp_validate(otpemailid character varying, entered_otp integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
  actual_otp integer;
  expiry_timestamp timestamptz;
BEGIN
  SELECT otp_no, otp_gendatetime+ INTERVAL '30 minutes' 
  INTO actual_otp, expiry_timestamp
  FROM otp_tbl
  WHERE otp_emailid = otpemailid AND otp_activeyn='Y' AND otp_latestyn='Y';
  
  IF (entered_otp = actual_otp)AND (expiry_timestamp > now())  THEN
    RETURN 'OTP is correct';
  ELSE
    RETURN 'OTP is incorrect or has expired';
  END IF;
END;
$$;
 V   DROP FUNCTION public.otp_validate(otpemailid character varying, entered_otp integer);
       public          postgres    false            �            1255    24964 �   project_create(character varying, character varying, date, date, character varying, integer, character varying, character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.project_create(p_project_name character varying, p_project_type character varying, p_project_start_date date, p_project_end_date date, p_project_description character varying, p_project_budget integer, p_project_billable character varying, p_project_manager character varying, p_project_status character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
proj_id character varying;   
BEGIN
	SELECT 'PROJ' || lpad(CAST(COALESCE(max(substring(projdtl_id, 4)::integer), 0) + 1 AS TEXT), 5, '0') INTO proj_id FROM projdtl_tbl;
	
	INSERT INTO projdtl_tbl (
		projdtl_id,
        projdtl_name,
        projdtl_type,
        projdtl_startdate,
        projdtl_enddate,
        projdtl_description,
        projdtl_budget,
        projdtl_billable,
        projdtl_managerid,
        projdtl_status
    ) VALUES (
		proj_id,
        p_project_name,
        p_project_type,
        p_project_start_date,
        p_project_end_date,
        p_project_description,
        p_project_budget,
        p_project_billable,
        p_project_manager,
        p_project_status
    );

	
RETURN 'Project Created!';
END;
$$;
 O  DROP FUNCTION public.project_create(p_project_name character varying, p_project_type character varying, p_project_start_date date, p_project_end_date date, p_project_description character varying, p_project_budget integer, p_project_billable character varying, p_project_manager character varying, p_project_status character varying);
       public          postgres    false            �            1259    24743    bank_master    TABLE     �   CREATE TABLE public.bank_master (
    bank_id character varying(5) NOT NULL,
    bank_name character varying(50),
    bank_activeyn character varying(1)
);
    DROP TABLE public.bank_master;
       public         heap    postgres    false            �            1259    24748    branch_master    TABLE     �  CREATE TABLE public.branch_master (
    branch_id character varying(5) NOT NULL,
    branch_ifsc character varying(20),
    branch_name character varying(50),
    branch_micr integer,
    bank_address character varying(50),
    bank_city character varying(50),
    bank_district character varying(50),
    bank_state character varying(50),
    branch_activeyn character varying(1)
);
 !   DROP TABLE public.branch_master;
       public         heap    postgres    false            �            1259    24753    designation_master    TABLE     �   CREATE TABLE public.designation_master (
    designation_id character varying(5) NOT NULL,
    designation_name character varying(50),
    designation_activeyn character varying(1)
);
 &   DROP TABLE public.designation_master;
       public         heap    postgres    false            �            1259    24758 
   doc_master    TABLE     �   CREATE TABLE public.doc_master (
    doc_id character varying(5) NOT NULL,
    doc_name character varying(50),
    doc_activeyn character varying(1)
);
    DROP TABLE public.doc_master;
       public         heap    postgres    false            �            1259    24763    empbankdtl_tbl    TABLE     �  CREATE TABLE public.empbankdtl_tbl (
    empbankdtl_name character varying(30),
    empbankdtl_accno character varying(50) NOT NULL,
    empbankdtl_activeyn character varying(1),
    empbankdtl_delreason character varying(500),
    system_date timestamp without time zone,
    system_user character varying(50),
    system_host character varying(50),
    empreg_id character varying(50)
);
 "   DROP TABLE public.empbankdtl_tbl;
       public         heap    postgres    false            �            1259    24770 
   empdoc_tbl    TABLE     �   CREATE TABLE public.empdoc_tbl (
    empdoc_id integer NOT NULL,
    empdoc_name character varying(50),
    empdoc_file bytea,
    empreg_id character varying(50)
);
    DROP TABLE public.empdoc_tbl;
       public         heap    postgres    false            �            1259    24796    empnomineedtl_tbl    TABLE     j  CREATE TABLE public.empnomineedtl_tbl (
    empnomineedtl_id integer NOT NULL,
    empnomineedtl_firstname character varying(50),
    empnomineedtl_middlename character varying(50),
    empnomineedtl_lastname character varying(20),
    empnomineedtl_gender character varying(1),
    empnomineedtl_mobile integer,
    empnomineedtl_activeyn character varying(1),
    empnomineedtl_delreason character varying(500),
    system_date timestamp without time zone,
    system_user character varying(50),
    system_host character varying(50),
    empreg_id character varying(50),
    relationship_id character varying(5)
);
 %   DROP TABLE public.empnomineedtl_tbl;
       public         heap    postgres    false            �            1259    16450 
   empreg_tbl    TABLE     A  CREATE TABLE public.empreg_tbl (
    empreg_id character varying(50) NOT NULL,
    empreg_fname character varying(50),
    empreg_mname character varying(50),
    empreg_lname character varying(50),
    empreg_usertype character varying(1),
    empreg_gender character varying(1),
    empreg_dob date,
    empreg_age integer,
    empreg_marital_status character varying(1),
    empreg_nationality character varying(25),
    empreg_disability character varying(1),
    empreg_email character varying(30),
    empreg_mobile integer,
    empreg_uan integer,
    empreg_esic integer,
    empreg_pan character varying(25),
    empreg_aadhar integer,
    empreg_city character varying(50),
    empreg_state character varying(50),
    empreg_pincode integer,
    empreg_landmark character varying(100),
    empreg_activeyn character varying(1),
    empreg_delreason character varying(500),
    system_date timestamp without time zone,
    system_user character varying(50),
    system_host character varying(50),
    orgreg_id character varying(50),
    empreg_password character varying(100)
);
    DROP TABLE public.empreg_tbl;
       public         heap    postgres    false            �            1259    24808    empsalarydtl_tbl    TABLE     Y  CREATE TABLE public.empsalarydtl_tbl (
    empsalarydtl_id character varying(50) NOT NULL,
    empsalarydtl_basic numeric(16,1),
    empsalarydtl_hra numeric(16,1),
    empsalarydtl_internetallowance numeric(16,1),
    empsalarydtl_conveyanceallowance numeric(16,1),
    empsalarydtl_pf numeric(16,1),
    empsalarydtl_total numeric(16,1),
    empsalarydtl_activeyn character varying(1),
    empsalarydtl_delreason character varying(500),
    system_date timestamp without time zone,
    system_user character varying(50),
    system_host character varying(50),
    empreg_id character varying(50)
);
 $   DROP TABLE public.empsalarydtl_tbl;
       public         heap    postgres    false            �            1259    24846    leaveapproval_tbl    TABLE     �  CREATE TABLE public.leaveapproval_tbl (
    leaveapproval_id character varying(50) NOT NULL,
    leave_isaccepted character varying(1),
    leave_comment character varying(100),
    leave_activeyn character varying(1),
    leave_delreason character varying(500),
    system_date timestamp without time zone,
    system_user character varying(50),
    system_host character varying(50),
    leavedtl_id character varying(50)
);
 %   DROP TABLE public.leaveapproval_tbl;
       public         heap    postgres    false            �            1259    24834    leavedtl_tbl    TABLE     �  CREATE TABLE public.leavedtl_tbl (
    leavedtl_id character varying(50) NOT NULL,
    leavedtl_description character varying(200),
    leavedtl_isfullday character varying(1),
    leavedtl_fromdate date,
    leavedtl_todate date,
    leavedtl_totaldays integer,
    leavedtl_ispaid character varying(1),
    leavedtl_approverdesignation character varying(20),
    leavedtl_approverid integer,
    leavedtl_activeyn character varying(1),
    leavedtl_delreason character varying(500),
    system_date timestamp without time zone,
    system_user character varying(50),
    system_host character varying(50),
    empreg_id character varying(50),
    leavetype_id character varying(50)
);
     DROP TABLE public.leavedtl_tbl;
       public         heap    postgres    false            �            1259    24858    leavefwd_tbl    TABLE     �  CREATE TABLE public.leavefwd_tbl (
    leavefwd_id character varying(50) NOT NULL,
    leavefwd_comment character varying(100),
    leavefwd_latestyn character varying(1),
    leavefwd_activeyn character varying(1),
    leavetfwd_delreason character varying(500),
    system_date timestamp without time zone,
    system_user character varying(50),
    system_host character varying(50),
    leavedtl_id character varying(50),
    designation_id character varying(50),
    empreg_id character varying(50)
);
     DROP TABLE public.leavefwd_tbl;
       public         heap    postgres    false            �            1259    24829    leavetype_master    TABLE     �   CREATE TABLE public.leavetype_master (
    leavetype_id character varying(5) NOT NULL,
    leavetype_name character varying(50),
    leavetype_activeyn character varying(1)
);
 $   DROP TABLE public.leavetype_master;
       public         heap    postgres    false            �            1259    24875 
   orgdoc_tbl    TABLE     �  CREATE TABLE public.orgdoc_tbl (
    orgdoc_srno integer NOT NULL,
    orgdoc_file bytea NOT NULL,
    orgdoc_ext character varying(25),
    orgdoc_activeyn character varying(1),
    orgdoc_delreason character varying(500),
    system_date timestamp without time zone,
    system_user character varying(50),
    system_host character varying(50),
    orgreg_id character varying(50),
    doc_id character varying(5)
);
    DROP TABLE public.orgdoc_tbl;
       public         heap    postgres    false            �            1259    16400 
   orgreg_tbl    TABLE     �  CREATE TABLE public.orgreg_tbl (
    orgreg_id character varying(50) NOT NULL,
    orgreg_name character varying(100),
    orgreg_address character varying(500),
    orgreg_email character varying(100),
    orgreg_regdate timestamp without time zone,
    orgreg_pan character varying(10),
    orgreg_contact character varying(15),
    orgreg_gstin character varying(25),
    orgreg_cni character varying(25),
    orgreg_activeyn character varying(1),
    orgreg_delreason character varying(500),
    system_date timestamp without time zone,
    system_user character varying(50),
    system_host character varying(50),
    orgtype_id character varying(5)
);
    DROP TABLE public.orgreg_tbl;
       public         heap    postgres    false            �            1259    24892    orgtype_master    TABLE     �   CREATE TABLE public.orgtype_master (
    orgtype_id character varying(5) NOT NULL,
    orgtype_name character varying(50),
    orgtype_activeyn character varying(1)
);
 "   DROP TABLE public.orgtype_master;
       public         heap    postgres    false            �            1259    24897    orgunitdtl_tbl    TABLE     �  CREATE TABLE public.orgunitdtl_tbl (
    orgunitdtl_srno integer NOT NULL,
    orgunitdtl_name character varying(100),
    orgunitdtl_address character varying(500),
    orgunitdtl_activeyn character varying(1),
    orgunitdtl_delreason character varying(500),
    system_date timestamp without time zone,
    system_user character varying(50),
    system_host character varying(50),
    orgreg_id character varying(50)
);
 "   DROP TABLE public.orgunitdtl_tbl;
       public         heap    postgres    false            �            1259    24965    otp_tbl    TABLE     �  CREATE TABLE public.otp_tbl (
    otp_emailid character varying(160) NOT NULL,
    otp_srno integer NOT NULL,
    otp_no integer NOT NULL,
    otp_gendatetime timestamp without time zone NOT NULL,
    otp_usedtime timestamp without time zone NOT NULL,
    otp_activeyn character varying(1) NOT NULL,
    otp_latestyn character varying(1) NOT NULL,
    system_date timestamp without time zone NOT NULL,
    system_user character varying(50) NOT NULL,
    system_host character varying(50) NOT NULL
);
    DROP TABLE public.otp_tbl;
       public         heap    postgres    false            �            1259    24977    projalloc_tbl    TABLE     �  CREATE TABLE public.projalloc_tbl (
    projalloc_id character varying(50) NOT NULL,
    involvement integer,
    fromdate timestamp without time zone,
    todate timestamp without time zone,
    system_date timestamp without time zone,
    system_user character varying(50),
    system_host character varying(50),
    projdtl_id character varying(50),
    designation_id character varying(50),
    empreg_id character varying(50)
);
 !   DROP TABLE public.projalloc_tbl;
       public         heap    postgres    false            �            1259    24970    projdtl_tbl    TABLE     z  CREATE TABLE public.projdtl_tbl (
    projdtl_id character varying(50) NOT NULL,
    projdtl_name character varying(20),
    projdtl_type character varying(50),
    projdtl_startdate date,
    projdtl_enddate date,
    projdtl_description character varying(100),
    projdtl_budget integer,
    projdtl_billable character varying(1),
    projdtl_managerid character varying(50),
    projdtl_status character varying(1),
    projdtl_activeyn character varying(1),
    projdtl_delreason character varying(500),
    system_date timestamp without time zone,
    system_user character varying(50),
    system_host character varying(50)
);
    DROP TABLE public.projdtl_tbl;
       public         heap    postgres    false            �            1259    24791    relationship_master    TABLE     �   CREATE TABLE public.relationship_master (
    relationship_id character varying(5) NOT NULL,
    relationship_name character varying(50),
    relationship_activeyn character varying(1)
);
 '   DROP TABLE public.relationship_master;
       public         heap    postgres    false            �            1259    24992    taskalloc_tbl    TABLE     �  CREATE TABLE public.taskalloc_tbl (
    taskalloc_id integer NOT NULL,
    taskalloc_description character varying(100),
    taskalloc_priority character varying(1),
    taskalloc_startdate date,
    taskalloc_estimateddate date,
    taskalloc_document bytea,
    taskalloc_isallocated character varying(1),
    taskalloc_status character varying(1),
    empreg_id character varying(50),
    projdtl_id character varying(50),
    designation_id character varying(50)
);
 !   DROP TABLE public.taskalloc_tbl;
       public         heap    postgres    false            �          0    24743    bank_master 
   TABLE DATA                 public          postgres    false    216   ^�       �          0    24748    branch_master 
   TABLE DATA                 public          postgres    false    217   x�       �          0    24753    designation_master 
   TABLE DATA                 public          postgres    false    218   ��       �          0    24758 
   doc_master 
   TABLE DATA                 public          postgres    false    219   ��       �          0    24763    empbankdtl_tbl 
   TABLE DATA                 public          postgres    false    220   Ə       �          0    24770 
   empdoc_tbl 
   TABLE DATA                 public          postgres    false    221   ��       �          0    24796    empnomineedtl_tbl 
   TABLE DATA                 public          postgres    false    223   ��       �          0    16450 
   empreg_tbl 
   TABLE DATA                 public          postgres    false    215   �       �          0    24808    empsalarydtl_tbl 
   TABLE DATA                 public          postgres    false    224   ��       �          0    24846    leaveapproval_tbl 
   TABLE DATA                 public          postgres    false    227   ��       �          0    24834    leavedtl_tbl 
   TABLE DATA                 public          postgres    false    226   ˙       �          0    24858    leavefwd_tbl 
   TABLE DATA                 public          postgres    false    228   �       �          0    24829    leavetype_master 
   TABLE DATA                 public          postgres    false    225   ��       �          0    24875 
   orgdoc_tbl 
   TABLE DATA                 public          postgres    false    229   �       �          0    16400 
   orgreg_tbl 
   TABLE DATA                 public          postgres    false    214   3�       �          0    24892    orgtype_master 
   TABLE DATA                 public          postgres    false    230   ��       �          0    24897    orgunitdtl_tbl 
   TABLE DATA                 public          postgres    false    231   ��       �          0    24965    otp_tbl 
   TABLE DATA                 public          postgres    false    232   ڠ       �          0    24977    projalloc_tbl 
   TABLE DATA                 public          postgres    false    234   ��       �          0    24970    projdtl_tbl 
   TABLE DATA                 public          postgres    false    233   �       �          0    24791    relationship_master 
   TABLE DATA                 public          postgres    false    222   (�       �          0    24992    taskalloc_tbl 
   TABLE DATA                 public          postgres    false    235   B�       �           2606    24747    bank_master bank_master_pkey 
   CONSTRAINT     _   ALTER TABLE ONLY public.bank_master
    ADD CONSTRAINT bank_master_pkey PRIMARY KEY (bank_id);
 F   ALTER TABLE ONLY public.bank_master DROP CONSTRAINT bank_master_pkey;
       public            postgres    false    216            �           2606    24752     branch_master branch_master_pkey 
   CONSTRAINT     e   ALTER TABLE ONLY public.branch_master
    ADD CONSTRAINT branch_master_pkey PRIMARY KEY (branch_id);
 J   ALTER TABLE ONLY public.branch_master DROP CONSTRAINT branch_master_pkey;
       public            postgres    false    217            �           2606    24757 *   designation_master designation_master_pkey 
   CONSTRAINT     t   ALTER TABLE ONLY public.designation_master
    ADD CONSTRAINT designation_master_pkey PRIMARY KEY (designation_id);
 T   ALTER TABLE ONLY public.designation_master DROP CONSTRAINT designation_master_pkey;
       public            postgres    false    218            �           2606    24762    doc_master doc_master_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.doc_master
    ADD CONSTRAINT doc_master_pkey PRIMARY KEY (doc_id);
 D   ALTER TABLE ONLY public.doc_master DROP CONSTRAINT doc_master_pkey;
       public            postgres    false    219            �           2606    24769 "   empbankdtl_tbl empbankdtl_tbl_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY public.empbankdtl_tbl
    ADD CONSTRAINT empbankdtl_tbl_pkey PRIMARY KEY (empbankdtl_accno);
 L   ALTER TABLE ONLY public.empbankdtl_tbl DROP CONSTRAINT empbankdtl_tbl_pkey;
       public            postgres    false    220            �           2606    24776    empdoc_tbl empdoc_tbl_pkey 
   CONSTRAINT     _   ALTER TABLE ONLY public.empdoc_tbl
    ADD CONSTRAINT empdoc_tbl_pkey PRIMARY KEY (empdoc_id);
 D   ALTER TABLE ONLY public.empdoc_tbl DROP CONSTRAINT empdoc_tbl_pkey;
       public            postgres    false    221            �           2606    24802 (   empnomineedtl_tbl empnomineedtl_tbl_pkey 
   CONSTRAINT     t   ALTER TABLE ONLY public.empnomineedtl_tbl
    ADD CONSTRAINT empnomineedtl_tbl_pkey PRIMARY KEY (empnomineedtl_id);
 R   ALTER TABLE ONLY public.empnomineedtl_tbl DROP CONSTRAINT empnomineedtl_tbl_pkey;
       public            postgres    false    223            �           2606    16456    empreg_tbl empreg_tbl_pkey 
   CONSTRAINT     _   ALTER TABLE ONLY public.empreg_tbl
    ADD CONSTRAINT empreg_tbl_pkey PRIMARY KEY (empreg_id);
 D   ALTER TABLE ONLY public.empreg_tbl DROP CONSTRAINT empreg_tbl_pkey;
       public            postgres    false    215            �           2606    24814 &   empsalarydtl_tbl empsalarydtl_tbl_pkey 
   CONSTRAINT     q   ALTER TABLE ONLY public.empsalarydtl_tbl
    ADD CONSTRAINT empsalarydtl_tbl_pkey PRIMARY KEY (empsalarydtl_id);
 P   ALTER TABLE ONLY public.empsalarydtl_tbl DROP CONSTRAINT empsalarydtl_tbl_pkey;
       public            postgres    false    224            �           2606    24852 (   leaveapproval_tbl leaveapproval_tbl_pkey 
   CONSTRAINT     t   ALTER TABLE ONLY public.leaveapproval_tbl
    ADD CONSTRAINT leaveapproval_tbl_pkey PRIMARY KEY (leaveapproval_id);
 R   ALTER TABLE ONLY public.leaveapproval_tbl DROP CONSTRAINT leaveapproval_tbl_pkey;
       public            postgres    false    227            �           2606    24840    leavedtl_tbl leavedtl_tbl_pkey 
   CONSTRAINT     e   ALTER TABLE ONLY public.leavedtl_tbl
    ADD CONSTRAINT leavedtl_tbl_pkey PRIMARY KEY (leavedtl_id);
 H   ALTER TABLE ONLY public.leavedtl_tbl DROP CONSTRAINT leavedtl_tbl_pkey;
       public            postgres    false    226            �           2606    24864    leavefwd_tbl leavefwd_tbl_pkey 
   CONSTRAINT     e   ALTER TABLE ONLY public.leavefwd_tbl
    ADD CONSTRAINT leavefwd_tbl_pkey PRIMARY KEY (leavefwd_id);
 H   ALTER TABLE ONLY public.leavefwd_tbl DROP CONSTRAINT leavefwd_tbl_pkey;
       public            postgres    false    228            �           2606    24833 &   leavetype_master leavetype_master_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY public.leavetype_master
    ADD CONSTRAINT leavetype_master_pkey PRIMARY KEY (leavetype_id);
 P   ALTER TABLE ONLY public.leavetype_master DROP CONSTRAINT leavetype_master_pkey;
       public            postgres    false    225            �           2606    24881    orgdoc_tbl orgdoc_tbl_pkey 
   CONSTRAINT     a   ALTER TABLE ONLY public.orgdoc_tbl
    ADD CONSTRAINT orgdoc_tbl_pkey PRIMARY KEY (orgdoc_srno);
 D   ALTER TABLE ONLY public.orgdoc_tbl DROP CONSTRAINT orgdoc_tbl_pkey;
       public            postgres    false    229            �           2606    16406    orgreg_tbl orgreg_tbl_pkey 
   CONSTRAINT     _   ALTER TABLE ONLY public.orgreg_tbl
    ADD CONSTRAINT orgreg_tbl_pkey PRIMARY KEY (orgreg_id);
 D   ALTER TABLE ONLY public.orgreg_tbl DROP CONSTRAINT orgreg_tbl_pkey;
       public            postgres    false    214            �           2606    24896 "   orgtype_master orgtype_master_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.orgtype_master
    ADD CONSTRAINT orgtype_master_pkey PRIMARY KEY (orgtype_id);
 L   ALTER TABLE ONLY public.orgtype_master DROP CONSTRAINT orgtype_master_pkey;
       public            postgres    false    230            �           2606    24903 "   orgunitdtl_tbl orgunitdtl_tbl_pkey 
   CONSTRAINT     m   ALTER TABLE ONLY public.orgunitdtl_tbl
    ADD CONSTRAINT orgunitdtl_tbl_pkey PRIMARY KEY (orgunitdtl_srno);
 L   ALTER TABLE ONLY public.orgunitdtl_tbl DROP CONSTRAINT orgunitdtl_tbl_pkey;
       public            postgres    false    231            �           2606    24969    otp_tbl otp_tbl_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.otp_tbl
    ADD CONSTRAINT otp_tbl_pkey PRIMARY KEY (otp_srno);
 >   ALTER TABLE ONLY public.otp_tbl DROP CONSTRAINT otp_tbl_pkey;
       public            postgres    false    232            �           2606    24981     projalloc_tbl projalloc_tbl_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.projalloc_tbl
    ADD CONSTRAINT projalloc_tbl_pkey PRIMARY KEY (projalloc_id);
 J   ALTER TABLE ONLY public.projalloc_tbl DROP CONSTRAINT projalloc_tbl_pkey;
       public            postgres    false    234            �           2606    24976    projdtl_tbl projdtl_tbl_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.projdtl_tbl
    ADD CONSTRAINT projdtl_tbl_pkey PRIMARY KEY (projdtl_id);
 F   ALTER TABLE ONLY public.projdtl_tbl DROP CONSTRAINT projdtl_tbl_pkey;
       public            postgres    false    233            �           2606    24795 ,   relationship_master relationship_master_pkey 
   CONSTRAINT     w   ALTER TABLE ONLY public.relationship_master
    ADD CONSTRAINT relationship_master_pkey PRIMARY KEY (relationship_id);
 V   ALTER TABLE ONLY public.relationship_master DROP CONSTRAINT relationship_master_pkey;
       public            postgres    false    222            �           2606    24998     taskalloc_tbl taskalloc_tbl_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.taskalloc_tbl
    ADD CONSTRAINT taskalloc_tbl_pkey PRIMARY KEY (taskalloc_id);
 J   ALTER TABLE ONLY public.taskalloc_tbl DROP CONSTRAINT taskalloc_tbl_pkey;
       public            postgres    false    235            �           2606    24803 8   empnomineedtl_tbl empnomineedtl_tbl_relationship_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.empnomineedtl_tbl
    ADD CONSTRAINT empnomineedtl_tbl_relationship_id_fkey FOREIGN KEY (relationship_id) REFERENCES public.relationship_master(relationship_id);
 b   ALTER TABLE ONLY public.empnomineedtl_tbl DROP CONSTRAINT empnomineedtl_tbl_relationship_id_fkey;
       public          postgres    false    222    223    3278            �           2606    16457 $   empreg_tbl empreg_tbl_orgreg_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.empreg_tbl
    ADD CONSTRAINT empreg_tbl_orgreg_id_fkey FOREIGN KEY (orgreg_id) REFERENCES public.orgreg_tbl(orgreg_id);
 N   ALTER TABLE ONLY public.empreg_tbl DROP CONSTRAINT empreg_tbl_orgreg_id_fkey;
       public          postgres    false    215    3262    214            �           2606    24853 4   leaveapproval_tbl leaveapproval_tbl_leavedtl_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.leaveapproval_tbl
    ADD CONSTRAINT leaveapproval_tbl_leavedtl_id_fkey FOREIGN KEY (leavedtl_id) REFERENCES public.leavedtl_tbl(leavedtl_id);
 ^   ALTER TABLE ONLY public.leaveapproval_tbl DROP CONSTRAINT leaveapproval_tbl_leavedtl_id_fkey;
       public          postgres    false    227    3286    226            �           2606    24841 +   leavedtl_tbl leavedtl_tbl_leavetype_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.leavedtl_tbl
    ADD CONSTRAINT leavedtl_tbl_leavetype_id_fkey FOREIGN KEY (leavetype_id) REFERENCES public.leavetype_master(leavetype_id);
 U   ALTER TABLE ONLY public.leavedtl_tbl DROP CONSTRAINT leavedtl_tbl_leavetype_id_fkey;
       public          postgres    false    226    3284    225            �           2606    24865 -   leavefwd_tbl leavefwd_tbl_designation_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.leavefwd_tbl
    ADD CONSTRAINT leavefwd_tbl_designation_id_fkey FOREIGN KEY (designation_id) REFERENCES public.designation_master(designation_id);
 W   ALTER TABLE ONLY public.leavefwd_tbl DROP CONSTRAINT leavefwd_tbl_designation_id_fkey;
       public          postgres    false    228    3270    218            �           2606    24870 *   leavefwd_tbl leavefwd_tbl_leavedtl_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.leavefwd_tbl
    ADD CONSTRAINT leavefwd_tbl_leavedtl_id_fkey FOREIGN KEY (leavedtl_id) REFERENCES public.leavedtl_tbl(leavedtl_id);
 T   ALTER TABLE ONLY public.leavefwd_tbl DROP CONSTRAINT leavefwd_tbl_leavedtl_id_fkey;
       public          postgres    false    228    3286    226            �           2606    24882 !   orgdoc_tbl orgdoc_tbl_doc_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.orgdoc_tbl
    ADD CONSTRAINT orgdoc_tbl_doc_id_fkey FOREIGN KEY (doc_id) REFERENCES public.doc_master(doc_id);
 K   ALTER TABLE ONLY public.orgdoc_tbl DROP CONSTRAINT orgdoc_tbl_doc_id_fkey;
       public          postgres    false    219    229    3272            �           2606    24887 $   orgdoc_tbl orgdoc_tbl_orgreg_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.orgdoc_tbl
    ADD CONSTRAINT orgdoc_tbl_orgreg_id_fkey FOREIGN KEY (orgreg_id) REFERENCES public.orgreg_tbl(orgreg_id);
 N   ALTER TABLE ONLY public.orgdoc_tbl DROP CONSTRAINT orgdoc_tbl_orgreg_id_fkey;
       public          postgres    false    229    3262    214            �           2606    24904 ,   orgunitdtl_tbl orgunitdtl_tbl_orgreg_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.orgunitdtl_tbl
    ADD CONSTRAINT orgunitdtl_tbl_orgreg_id_fkey FOREIGN KEY (orgreg_id) REFERENCES public.orgreg_tbl(orgreg_id);
 V   ALTER TABLE ONLY public.orgunitdtl_tbl DROP CONSTRAINT orgunitdtl_tbl_orgreg_id_fkey;
       public          postgres    false    214    231    3262            �           2606    24982 /   projalloc_tbl projalloc_tbl_designation_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.projalloc_tbl
    ADD CONSTRAINT projalloc_tbl_designation_id_fkey FOREIGN KEY (designation_id) REFERENCES public.designation_master(designation_id);
 Y   ALTER TABLE ONLY public.projalloc_tbl DROP CONSTRAINT projalloc_tbl_designation_id_fkey;
       public          postgres    false    218    234    3270            �           2606    24987 +   projalloc_tbl projalloc_tbl_projdtl_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.projalloc_tbl
    ADD CONSTRAINT projalloc_tbl_projdtl_id_fkey FOREIGN KEY (projdtl_id) REFERENCES public.projdtl_tbl(projdtl_id);
 U   ALTER TABLE ONLY public.projalloc_tbl DROP CONSTRAINT projalloc_tbl_projdtl_id_fkey;
       public          postgres    false    3300    233    234            �           2606    24999 /   taskalloc_tbl taskalloc_tbl_designation_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.taskalloc_tbl
    ADD CONSTRAINT taskalloc_tbl_designation_id_fkey FOREIGN KEY (designation_id) REFERENCES public.designation_master(designation_id);
 Y   ALTER TABLE ONLY public.taskalloc_tbl DROP CONSTRAINT taskalloc_tbl_designation_id_fkey;
       public          postgres    false    235    218    3270            �           2606    25004 +   taskalloc_tbl taskalloc_tbl_projdtl_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.taskalloc_tbl
    ADD CONSTRAINT taskalloc_tbl_projdtl_id_fkey FOREIGN KEY (projdtl_id) REFERENCES public.projdtl_tbl(projdtl_id);
 U   ALTER TABLE ONLY public.taskalloc_tbl DROP CONSTRAINT taskalloc_tbl_projdtl_id_fkey;
       public          postgres    false    3300    233    235            �   
   x���          �   
   x���          �   
   x���          �   
   x���          �   
   x���          �   
   x���          �   
   x���          �   s	  x���]o�F���
ݹZb��|io�A7@�MZ�W��Zjd�+�	��w(&�pe�"D��!�D�X~4�;�^�~���w����6��+W˪�7��x�~W�f�}~���}~ج�M|غl�[wm���o;�㺎ۇ�zS><��1�v����.��ڇ��[n�a����lC��7a�:k��Y�����e��q�B����*?zצ��n��jSg�Xש���vˏ��p�:��1�����ow��}�?���%{�Xl������~��m?m����?�^����컋�ި�.~�]�ن6�����?^�L;^���!lv�����jg?oV�x}��Uۆ�y�QG����~~� �/����1y>&QL��3I�ɫr�\�vq@�.�>�M^\�CB!$�.�o�js�û���
TH?*�x�8�~NTXk��e�w �U h���~��������'^��=3�<�4W	0�X���^��WOH/ϵ+��ʚL�׫E�y�5��K0WT :�kr�]#tϛ�ڶ!5�`��",?,�&7�]���z�����\�9��A����Mt���oLi�<'��!*݀7�6V>�.r����*�`B�M�k�|)����T�;�������������{��4| �>3�ƌ;1.Ə��/��X������+�/�E�ʡ�
����}�XoK!�a�{�c]�� z�* `c�:FM_6�X5���̜��T�^އl
yV�)Ig3'S�c�� �o�#�����"} }/�u�dc�����q�Q͔J]�M:�D��i��Y�.֏��$�w3��0�0dӀ}���/�jJ���%׬T%a��Q����2*b�@��*�	\���X?3�4�fX�' �Y�1����j��ԩ'w�E�����ƀ���Rz+(��$��8�������YL#v�~f�y�	�3S�]6�7�1���ڸ���p��/�;E�Mh����)�����%hmh8�6��3���a����Y�l�o�c���2T1X �.��P�I�@1\�M��-�Hdһ `���iU��>�J���u3	���lf�&>��?f݈u�~d�NźօgK�1�XR�ĺXXw����\�4^��s�c�i_�b}`�O�:P����Դ/�u��[G5�ԝ�z Y��c�i_�b}`}�i��T ��,K±ܴ/�u�>�>�ܴ�n`˘eI8����.�֧�����x�l~�rӾ �����4r�޺�Z��c�i_�b}`}�ig������Xn�����c���M{�d![��c�)Jn*֏�O#7վ�1R������(��X?�>���d�M���_�MQrS�~l}
�io��k���/�MQrS�~d����Bw�)Raɲˬ�XnJ����c�S�M��	
���l���$��X?�>���un����rS��T�[�Bn�[�"qU:Ì�$��X?�>���u�>�����$��H?�>��t/�}�=��RSKMIRS�~l}
�i���J�*�w�c�)Ih*ԏ�O!4�S׶`�}�Ƒ�2S��T�S�Ff�aN\X6�e�h,3%�L�������ۻ�rup�������޴�%(��������aj�8G��w�)ˌ��}A7�l�gU� t�TV5%:SZ��#����P���*A^�YM=uw�3V[�V��X�����������r%�S�����8E�h��3�<���A/��i��Y3��D��־ �� =O��H6[U�cYk_�~����/����1�j1�Z��X��'���ֹ��ɧ��<�Ɒ�/�u�>�~�ako]'�s�����־ ԅ���ɇ�_�ڰq���X��ĺXX?�T{�f� �0����2V��U�Y�'�jo����T�E�Z�U�~l��/P�['�YW`����c���@U�S?��S{�f�\a�Q�y�z,GՒ���c�'}��:C�]h�.�O�X|�%>���O����_7�����TKf*ҏ����z���C{p�:l?�a�$���(�p� wӎL���{����s!x��6uYW3[���E��cUǺq1�5�+���P^��Jj,��3��۬ﳾ}���$����{����r]}�����l��z,A�U�L�&:P�����Λ�"�8�ʦ7��L��`�UQy�������o�ǰ>8{�����/�k���,ª��wH#�o����\�9B�����h�"վ��K�ں.���Q�4�Ԡ+�mtk��ݺ���aS�b�����\��x���^�f=qAd(����+k��gi���a���{p�P�/(�S&�J����xc�`c��.rz/�����epijo��|)��L��z��w�=�7���4��>{�� N賥z,^��^��ꍚ�z�}2����lToƂ־�5�?{�_z�e�      �   
   x���          �   
   x���          �   
   x���          �   
   x���          �   
   x���          �   
   x���          �   c  x���]s�F�{~��j�����Po�&�MC�\1�-l5�e,��ߕ+D�Y��ӛ�d,�y-Γ�V��]^��p�]^��V��y6F�z�N��7������l�2zx�Li��L&�(��t�d�f�~M���Wɲy<Η�d�i���&���e���M�-����$��Ӥ���ߋM��\���ƶH���,/���|_����"�t|���U�|���)���e4Z-��宣q�(��b�M)�N'�/v����y���>;��W�B���j���ǿ�=���ϣ����{��m�<���W��"<�4&f)���勿��JXB:]F7=s^CG����N�{*��SD4�W��ys��!���V<a��AV���v�m��=��� �%&���1C�ED�X;�p5\���j�dw��t�oWQ�ŪM��f��E��E��IG�EDx�EL4�D�������P�_���J�ER̒�b�5~TY?+��.��b7�����y�8Td;F�=`1LMV+g�8�-@�RU��d�c���bv(dG�'�ÙZA�!���� �ea./�J\�L"�9U:H�Jn%�s@QalAL�=�S���{Su���zQ�So����� �vP�������7�N�èZA@��^Tv�f'���N�����M%��LLb�c5t��Tn*�E�M��S)���A@�R�TB �< ����M����1���MU;��T}M�	C��H(Փ �rRQ�G��ـ!L��K�vP�����!��Q�%p;��T~݊��
�8�n��ʯ[QW�ICY�uU;��T~݊��F	~�zTn*�nEYa��0��S�Tn*�nE]a�(%C?��*7�_�B�r�eJ�N+ZA@���V���r%��Q�Tn*�nE]a�����k����I�|��\ARLqF�*7�O���0#H���v�~P��|��
k��>�*7�O���0E�j���� �rS�t+v��]��Ln&�NEU_n줍Sҩ�*7�O��VX�X ��
ROs ��ӧ�
,�J����^@�����^�r��4:���Tn�]�������N�.+SSl�1��������Bcs�ߪ3��.��_v'2�	{�;���Ʊ�+W1Ke�`u�[+��܈�Gk���p�ۏA���F��QI�	<N����ύqん�������ύq��2%��� p�s����U�$��rpӷ3��n��}��¼��������� �rS��|���Hk#��� ��w�cW`Ɛ�\����� �rS�^�QWX�� b0�IrgP9�D��u�UUa�I褢Tn���3�
3\V9�.%�9 ��:�.���F�k6���A@��:��0'�/�^��8�3��T�Wg4��A���`r3U�:ݮ��I�\N��^s��Y��4�� =%�Vu���$���/���&_�u��Uw�R1S�P�k/�
vm��y�CG��l9��~���}r�,��ME��BǔTw۔����A3[��f1K�Ez�����h��y�Ͽ%�]q�
�jzG��ט�a�%��#�R���C�=�������';�~>�Ŷ���1�`�p[�a}�CA�r�J�!ƙCO��z����1J�a��CA���=�>Q>�      �   
   x���          �   
   x���          �   
   x���          �   
   x���          �   
   x���          �   
   x���          �   
   x���         