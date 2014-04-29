
-- ALTER TABLE IF EXISTS "passport"."Validation" DROP CONSTRAINT "fk_Validations_AppId";
-- ALTER TABLE IF EXISTS "passport"."Passport" DROP CONSTRAINT "fk_Passport_Application";
-- ALTER TABLE IF EXISTS "passport"."Citizen" DROP CONSTRAINT "fk_Citizen_user";
-- ALTER TABLE IF EXISTS "passport"."ValidationAuthority" DROP CONSTRAINT "fk_ValidationAuthority_VAemail";
-- ALTER TABLE IF EXISTS "passport"."PassportGrantingOfficer" DROP CONSTRAINT "fk_PassportGrantingOfficer_user";
-- ALTER TABLE IF EXISTS "passport"."PassportApplication" DROP CONSTRAINT "fk_PassportApplication";
-- ALTER TABLE IF EXISTS "passport"."Validation" DROP CONSTRAINT "fk_Validation";
-- ALTER TABLE IF EXISTS "passport"."PassportApplication" DROP CONSTRAINT "fk_PassportApplication_1";
-- ALTER TABLE IF EXISTS "passport"."PassportApplication" DROP CONSTRAINT "fk_PassportApplication_2";
-- ALTER TABLE IF EXISTS "passport"."Region" DROP CONSTRAINT "fk_Region";

-- DROP TABLE IF EXISTS "passport"."Citizen";
-- DROP TABLE IF EXISTS "passport"."PassportApplication";
-- DROP TABLE IF EXISTS "passport"."Validation";
-- DROP TABLE IF EXISTS "passport"."ValidationAuthority";
-- DROP TABLE IF EXISTS "passport"."Passport";
-- DROP TABLE IF EXISTS "passport"."PassportGrantingOfficer";
-- DROP TABLE IF EXISTS "passport"."User";
-- DROP TABLE IF EXISTS "passport"."Region";
-- DROP TABLE IF EXISTS "passport"."UnverifiedUser";

DROP SCHEMA IF EXISTS "passport" CASCADE ;
CREATE SCHEMA IF NOT EXISTS "passport" ;

CREATE TABLE IF NOT EXISTS "passport"."Citizen" (
"email" varchar(255) NOT NULL,
"GivenName" varchar(255) NOT NULL,
"Surname" varchar(255),
"HasAliases" char NOT NULL,
"HaveChangedName" char NOT NULL,
"ContactNumber" int,
"DateOfBirth" date NOT NULL,
"City" varchar(255) NOT NULL,
"Country" varchar(255) NOT NULL,
"State" varchar(255) NOT NULL,
"District" varchar(255) NOT NULL,
"Gender" char NOT NULL,
"MaritalStatus" char NOT NULL,
"CitizenshipBy" char NOT NULL,
"PAN" varchar(255),
"VoterID" varchar(255),
"EmploymentType" varchar(255) NOT NULL,
"EducationalQualification" varchar(255) NOT NULL,
"AadhaarNumber" int,
"FatherGivenName" varchar(255),
"FatherSurname" varchar(255),
"MotherGivenName" varchar(255),
"MotherSurname" varchar(255),
"LegalGuardianGivenName" varchar(255),
"LegalGuardianSurname" varchar(255),
"PresentAddressOutOfCountry" char NOT NULL,
"FirstReferenceNameandAddress" varchar(255) NOT NULL,
"FirstReferenceMobileNumber" int,
"SecondReferenceNameandAddress" varchar(255) NOT NULL,
"SecondReferenceMobileNumber" int,
"EmergencyNameAndAddress" varchar(255) NOT NULL,
"EmergencyMobileNumber" int,
"AppliedButNotIssued" char,
"PreviousPassportNumber" int,
"OtherDetails1" char NOT NULL,
"OtherDetails2" char NOT NULL,
"OtherDetails3" char NOT NULL,
"OtherDetails4" char NOT NULL,
"OtherDetails5" char NOT NULL,
"OtherDetails6" char NOT NULL,
PRIMARY KEY ("email")
);

CREATE TABLE IF NOT EXISTS "passport"."PassportApplication" (
"Id" int NOT NULL,
"CitizenEmail" varchar(225) NOT NULL,
"ApplyingFor" char NOT NULL,
"ApplicationType" char NOT NULL,
"PassportType" char NOT NULL,
"PassportBookletType" char NOT NULL,
"ValidityRequired" int,
"GrantingOfficerEmail" varchar(255),
"RegionId" int NOT NULL,
PRIMARY KEY ("Id")
);

CREATE TABLE IF NOT EXISTS "passport"."Validation" (
"ApplicationId" int NOT NULL,
"ValidationType" char NOT NULL,
"ValidationAuthorityEmail" varchar(255) NOT NULL,
"Status" char NOT NULL,
"Remarks" varchar(255),
PRIMARY KEY ("ApplicationId", "ValidationType")
);

CREATE TABLE IF NOT EXISTS "passport"."ValidationAuthority" (
"Name" varchar(255) NOT NULL,
"email" varchar(255) NOT NULL,
PRIMARY KEY ("email")
);

CREATE TABLE IF NOT EXISTS "passport"."Passport" (
"PassportNumber" int NOT NULL,
"DateOfIssue" date NOT NULL,
"DateOfExpiry" date NOT NULL,
"PlaceOfIssue" varchar(255) NOT NULL,
"ApplicationId" int4,
PRIMARY KEY ("PassportNumber")
);

CREATE TABLE IF NOT EXISTS "passport"."PassportGrantingOfficer" (
"email" varchar(255) NOT NULL,
"Name" varchar(255) NOT NULL,
PRIMARY KEY ("email")
);

CREATE TABLE IF NOT EXISTS "passport"."User" (
"email" varchar(255) NOT NULL,
"key" varchar(255) NOT NULL,
"salt" varchar(255) NOT NULL,
PRIMARY KEY ("email")
);

CREATE TABLE IF NOT EXISTS "passport"."Region" (
"Id" int NOT NULL,
"Name" varchar(255) NOT NULL,
"GrantingOfficerEmail" varchar(255),
PRIMARY KEY ("Id")
);

CREATE TABLE IF NOT EXISTS "passport"."UnverifiedUser" (
"email" varchar(255) NOT NULL,
"VerifiationKey" varchar(255) NOT NULL,
PRIMARY KEY ("VerifiationKey")
);


ALTER TABLE "passport"."Validation" ADD CONSTRAINT "fk_Validations_AppId" FOREIGN KEY ("ApplicationId") REFERENCES "passport"."PassportApplication" ("Id");
ALTER TABLE "passport"."Passport" ADD CONSTRAINT "fk_Passport_Application" FOREIGN KEY ("ApplicationId") REFERENCES "passport"."PassportApplication" ("Id");
ALTER TABLE "passport"."Citizen" ADD CONSTRAINT "fk_Citizen_user" FOREIGN KEY ("email") REFERENCES "passport"."User" ("email");
ALTER TABLE "passport"."ValidationAuthority" ADD CONSTRAINT "fk_ValidationAuthority_VAemail" FOREIGN KEY ("email") REFERENCES "passport"."User" ("email");
ALTER TABLE "passport"."PassportGrantingOfficer" ADD CONSTRAINT "fk_PassportGrantingOfficer_user" FOREIGN KEY ("email") REFERENCES "passport"."User" ("email");
ALTER TABLE "passport"."PassportApplication" ADD CONSTRAINT "fk_PassportApplication" FOREIGN KEY ("CitizenEmail") REFERENCES "passport"."Citizen" ("email");
ALTER TABLE "passport"."Validation" ADD CONSTRAINT "fk_Validation" FOREIGN KEY ("ValidationAuthorityEmail") REFERENCES "passport"."ValidationAuthority" ("email");
ALTER TABLE "passport"."PassportApplication" ADD CONSTRAINT "fk_PassportApplication_1" FOREIGN KEY ("GrantingOfficerEmail") REFERENCES "passport"."PassportGrantingOfficer" ("email");
ALTER TABLE "passport"."PassportApplication" ADD CONSTRAINT "fk_PassportApplication_2" FOREIGN KEY ("RegionId") REFERENCES "passport"."Region" ("Id");
ALTER TABLE "passport"."Region" ADD CONSTRAINT "fk_Region" FOREIGN KEY ("GrantingOfficerEmail") REFERENCES "passport"."PassportGrantingOfficer" ("email");


INSERT INTO "passport"."Region" ("Id", "Name") VALUES ( 1  , 'Ahmedabad' );
INSERT INTO "passport"."Region" ("Id", "Name") VALUES ( 2  , 'Amritsar' );
INSERT INTO "passport"."Region" ("Id", "Name") VALUES ( 5  , 'Bangalore' );
INSERT INTO "passport"."Region" ("Id", "Name") VALUES ( 4  , 'Bareilly' );
INSERT INTO "passport"."Region" ("Id", "Name") VALUES ( 7  , 'Bhopal' );
INSERT INTO "passport"."Region" ("Id", "Name") VALUES ( 3  , 'Bhubaneswar' );
INSERT INTO "passport"."Region" ("Id", "Name") VALUES ( 10 , 'Chandigarh' );
INSERT INTO "passport"."Region" ("Id", "Name") VALUES ( 26 , 'Chennai' );
INSERT INTO "passport"."Region" ("Id", "Name") VALUES ( 11 , 'Cochin' );
INSERT INTO "passport"."Region" ("Id", "Name") VALUES ( 9  , 'Coimbatore' );
INSERT INTO "passport"."Region" ("Id", "Name") VALUES ( 14 , 'Dehradun' );
INSERT INTO "passport"."Region" ("Id", "Name") VALUES ( 15 , 'Delhi' );
INSERT INTO "passport"."Region" ("Id", "Name") VALUES ( 18 , 'Ghaziabad' );
INSERT INTO "passport"."Region" ("Id", "Name") VALUES ( 16 , 'Goa' );
INSERT INTO "passport"."Region" ("Id", "Name") VALUES ( 17 , 'Guwahati' );
INSERT INTO "passport"."Region" ("Id", "Name") VALUES ( 19 , 'Hyderabad' );
INSERT INTO "passport"."Region" ("Id", "Name") VALUES ( 23 , 'Jaipur' );
INSERT INTO "passport"."Region" ("Id", "Name") VALUES ( 21 , 'Jalandhar' );
INSERT INTO "passport"."Region" ("Id", "Name") VALUES ( 22 , 'Jammu' );
INSERT INTO "passport"."Region" ("Id", "Name") VALUES ( 8  , 'Kolkata' );
INSERT INTO "passport"."Region" ("Id", "Name") VALUES ( 24 , 'Kozhikode' );
INSERT INTO "passport"."Region" ("Id", "Name") VALUES ( 25 , 'Lucknow' );
INSERT INTO "passport"."Region" ("Id", "Name") VALUES ( 27 , 'Madurai' );
INSERT INTO "passport"."Region" ("Id", "Name") VALUES ( 28 , 'Malappuram' );
INSERT INTO "passport"."Region" ("Id", "Name") VALUES ( 6  , 'Mumbai' );
INSERT INTO "passport"."Region" ("Id", "Name") VALUES ( 29 , 'Nagpur' );
INSERT INTO "passport"."Region" ("Id", "Name") VALUES ( 30 , 'Patna' );
INSERT INTO "passport"."Region" ("Id", "Name") VALUES ( 31 , 'Pune' );
INSERT INTO "passport"."Region" ("Id", "Name") VALUES ( 33 , 'Raipur' );
INSERT INTO "passport"."Region" ("Id", "Name") VALUES ( 32 , 'Ranchi' );
INSERT INTO "passport"."Region" ("Id", "Name") VALUES ( 35 , 'Shimla' );
INSERT INTO "passport"."Region" ("Id", "Name") VALUES ( 34 , 'Srinagar' );
INSERT INTO "passport"."Region" ("Id", "Name") VALUES ( 36 , 'Surat' );
INSERT INTO "passport"."Region" ("Id", "Name") VALUES ( 37 , 'Thane' );
INSERT INTO "passport"."Region" ("Id", "Name") VALUES ( 38 , 'Trichy' );
INSERT INTO "passport"."Region" ("Id", "Name") VALUES ( 39 , 'Trivandrum' );
INSERT INTO "passport"."Region" ("Id", "Name") VALUES ( 40 , 'Visakhapatnam' );
