user = require './user'

globals = require '../globals'
debug = globals.debug
PGConnect = globals.PGConnect

EntityName = '"passport"."Citizen"'

TYPE = 'Citizen'

class Citizen extends user.User

  constructor: (source, data) ->
    switch source
      when 'db'
        result = data
        super result.rows[0].email
        @GivenName = result.rows[0].GivenName
        @Surname = result.rows[0].Surname
        @HasAliases = result.rows[0].HasAliases
        @HaveChangedName = result.rows[0].HaveChangedName
        @ContactNumber = result.rows[0].ContactNumber
        @DateOfBirth = result.rows[0].DateOfBirth
        @City = result.rows[0].City
        @Country = result.rows[0].Country
        @State = result.rows[0].State
        @District = result.rows[0].District
        @Gender = result.rows[0].Gender
        @MaritalStatus = result.rows[0].MaritalStatus
        @CitizenshipBy = result.rows[0].CitizenshipBy
        @PAN = result.rows[0].PAN
        @VoterID = result.rows[0].VoterID
        @EmploymentType = result.rows[0].EmploymentType
        @EducationalQualification = result.rows[0].EducationalQualification
        @AadhaarNumber = result.rows[0].AadhaarNumber
        @FatherGivenName = result.rows[0].FatherGivenName
        @FatherSurname = result.rows[0].FatherSurname
        @MotherGivenName = result.rows[0].MotherGivenName
        @MotherSurname = result.rows[0].MotherSurname
        @LegalGuardianGivenName = result.rows[0].LegalGuardianGivenName
        @LegalGuardianSurname = result.rows[0].LegalGuardianSurname
        @PresentAddressOutOfCountry = result.rows[0].PresentAddressOutOfCountry
        @FirstReferenceNameandAddress = result.rows[0].FirstReferenceNameandAddress
        @FirstReferenceMobileNumber = result.rows[0].FirstReferenceMobileNumber
        @SecondReferenceNameandAddress = result.rows[0].SecondReferenceNameandAddress
        @SecondReferenceMobileNumber = result.rows[0].SecondReferenceMobileNumber
        @EmergencyNameAndAddress = result.rows[0].EmergencyNameAndAddress
        @EmergencyMobileNumber = result.rows[0].EmergencyMobileNumber
        @AppliedButNotIssued = result.rows[0].AppliedButNotIssued
        @PreviousPassportNumber = result.rows[0].PreviousPassportNumber
        @OtherDetails1 = result.rows[0].OtherDetails1
        @OtherDetails2 = result.rows[0].OtherDetails2
        @OtherDetails3 = result.rows[0].OtherDetails3
        @OtherDetails4 = result.rows[0].OtherDetails4
        @OtherDetails5 = result.rows[0].OtherDetails5
        @OtherDetails6 = result.rows[0].OtherDetails6
      when 'req'
        req = data
        super req.session.user.email
        @GivenName = req.param 'GivenName'
        @Surname = req.param 'Surname'
        @HasAliases = req.param 'HasAliases'
        @HaveChangedName = req.param 'HaveChangedName'
        @ContactNumber = req.param 'ContactNumber'
        @DateOfBirth = req.param 'DateOfBirth'
        @City = req.param 'City'
        @Country = req.param 'Country'
        @State = req.param 'State'
        @District = req.param 'District'
        @Gender = req.param 'Gender'
        @MaritalStatus = req.param 'MaritalStatus'
        @CitizenshipBy = req.param 'CitizenshipBy'
        @PAN = req.param 'PAN'
        @VoterID = req.param 'VoterID'
        @EmploymentType = req.param 'EmploymentType'
        @EducationalQualification = req.param 'EducationalQualification'
        @AadhaarNumber = req.param 'AadhaarNumber'
        @FatherGivenName = req.param 'FatherGivenName'
        @FatherSurname = req.param 'FatherSurname'
        @MotherGivenName = req.param 'MotherGivenName'
        @MotherSurname = req.param 'MotherSurname'
        @LegalGuardianGivenName = req.param 'LegalGuardianGivenName'
        @LegalGuardianSurname = req.param 'LegalGuardianSurname'
        @PresentAddressOutOfCountry = req.param 'PresentAddressOutOfCountry'
        @FirstReferenceNameandAddress = req.param 'FirstReferenceNameandAddress'
        @FirstReferenceMobileNumber = req.param 'FirstReferenceMobileNumber'
        @SecondReferenceNameandAddress = req.param 'SecondReferenceNameandAddress'
        @SecondReferenceMobileNumber = req.param 'SecondReferenceMobileNumber'
        @EmergencyNameAndAddress = req.param 'EmergencyNameAndAddress'
        @EmergencyMobileNumber = req.param 'EmergencyMobileNumber'
        @AppliedButNotIssued = req.param 'AppliedButNotIssued'
        @PreviousPassportNumber = req.param 'PreviousPassportNumber'
        @OtherDetails1 = req.param 'OtherDetails1'
        @OtherDetails2 = req.param 'OtherDetails2'
        @OtherDetails3 = req.param 'OtherDetails3'
        @OtherDetails4 = req.param 'OtherDetails4'
        @OtherDetails5 = req.param 'OtherDetails5'
        @OtherDetails6 = req.param 'OtherDetails6'
    @name = @GivenName + ' ' + @Surname
    @type = TYPE

  insertQuery: (client, done, callback) ->
    client.query
      name: "citizen_insert"
      text: "INSERT INTO #{EntityName} VALUES ( " +
        '$1::varchar , '  +  # email
        '$2::varchar , '  +  # GivenName
        '$3::varchar , '  +  # Surname
        '$4::char , '     +  # HasAliases
        '$5::char , '     +  # HaveChangedName
        '$6::varchar , '  +  # ContactNumber
        '$7::date , '     +  # DateOfBirth
        '$8::varchar , '  +  # City
        '$9::varchar , '  +  # Country
        '$10::varchar , ' + # State
        '$11::varchar , ' + # District
        '$12::char , '    + # Gender
        '$13::char , '    + # MaritalStatus
        '$14::char , '    + # CitizenshipBy
        '$15::varchar , ' + # PAN
        '$16::varchar , ' + # VoterID
        '$17::varchar , ' + # EmploymentType
        '$18::varchar , ' + # EducationalQualification
        '$19::varchar , ' + # AadhaarNumber
        '$20::varchar , ' + # FatherGivenName
        '$21::varchar , ' + # FatherSurname
        '$22::varchar , ' + # MotherGivenName
        '$23::varchar , ' + # MotherSurname
        '$24::varchar , ' + # LegalGuardianGivenName
        '$25::varchar , ' + # LegalGuardianSurname
        '$26::char , '    + # PresentAddressOutOfCountry
        '$27::varchar , ' + # FirstReferenceNameandAddress
        '$28::varchar , ' + # FirstReferenceMobileNumber
        '$29::varchar , ' + # SecondReferenceNameandAddress
        '$30::varchar , ' + # SecondReferenceMobileNumber
        '$31::varchar , ' + # EmergencyNameAndAddress
        '$32::varchar , ' + # EmergencyMobileNumber
        '$33::char , '    + # AppliedButNotIssued
        '$34::varchar , ' + # PreviousPassportNumber
        '$35::char , '    + # OtherDetails1
        '$36::char , '    + # OtherDetails2
        '$37::char , '    + # OtherDetails3
        '$38::char , '    + # OtherDetails4
        '$39::char , '    + # OtherDetails5
        '$40::char '      + # OtherDetails6
        " ) "
      values: [
        @email
        @GivenName
        @Surname
        @HasAliases
        @HaveChangedName
        @ContactNumber
        @DateOfBirth
        @City
        @Country
        @State
        @District
        @Gender
        @MaritalStatus
        @CitizenshipBy
        @PAN
        @VoterID
        @EmploymentType
        @EducationalQualification
        @AadhaarNumber
        @FatherGivenName
        @FatherSurname
        @MotherGivenName
        @MotherSurname
        @LegalGuardianGivenName
        @LegalGuardianSurname
        @PresentAddressOutOfCountry
        @FirstReferenceNameandAddress
        @FirstReferenceMobileNumber
        @SecondReferenceNameandAddress
        @SecondReferenceMobileNumber
        @EmergencyNameAndAddress
        @EmergencyMobileNumber
        @AppliedButNotIssued
        @PreviousPassportNumber
        @OtherDetails1
        @OtherDetails2
        @OtherDetails3
        @OtherDetails4
        @OtherDetails5
        @OtherDetails6
      ]
    , (err, result) ->
      if err
        done? client
        callback? err
        return
      done?()
      callback?()

  insertIntoDatabase: (client, callback) ->
    if typeof client is "function"
      callback = client
      client = undefined

    if client?
      @insertQuery client, null, callback
    else
      PGConnect (err, client, done) =>
        if err
          done? client
          callback? err
          return
        @insertQuery client, done, callback

addCitizen = (citizen, client, callback) ->
  debug "Adding Cititzen #{citizen.email}"
  citizen.insertIntoDatabase client, callback

getForEmail = (email, callback) ->
  PGConnect (err, client, done) ->
    if err
      done? client
      callback? err
      return
    client.query
      name: "get_citizen_for_email"
      text: "SELECT * FROM #{EntityName} WHERE \"email\" = $1::varchar"
      values: [email]
    , (err, result) ->
      if err
        done? client
        callback? err
        return
      done?()
      if result.rows[0]
        callback? null, new Citizen('db', result.rows[0])
      else
        callback? null, null

isCitizen = (email, callback) ->
  PGConnect (err, client, done) ->
    if err
      done? client
      callback? err
      return
    client.query
      name: "is_citizen"
      text: "SELECT count(*) AS exists FROM #{EntityName} WHERE email = $1::varchar"
      values: [email]
    , (err, result) ->
      if err
        done? client
        callback? err
        return
      done?()
      callback? null, result.rows[0].exists is '1'

attr_maps =
  MaritalStatus:
    's':'Single'
    'm':'Married'
    'd':'Divorced'
    'w':'Widow / Widower'
    'p':'Seperated'
  CitizenshipBy:
    'b':'Birth'
    'd':'Descent'
    'r':'Registration / Naturalization'
  EmploymentType:
    'a':'Government'
    'b':'Homemaker'
    'c':'Not Employed'
    'd':'Others'
    'e':'Owners, Partners &amp; Directors of companies which are mambers of CII, FICCI &amp; ASSOCHAM'
    'f':'Private'
    'g':'PSU'
    'h':'Retired - Government Servent'
    'i':'Retired - Private Service'
    'j':'Self Employed'
    'k':'Statutory Body'
    'l':'Student'
  EducationalQualification:
    'a':'5th pass or less'
    'b':'Between 6th and 9th standard'
    'c':'10th pass and above'
    'd':'Graduate and above'
  HasAliases:
    'y': 'Yes'
    'n': 'No'
  HaveChangedName:
    'y': 'Yes'
    'n': 'No'
  Gender:
    'm':'Male'
    'f':'Female'
  PresentAddressOutOfCountry:
    'y': 'Yes'
    'n': 'No'
  AppliedButNotIssued:
    'y': 'Yes'
    'n': 'No'
  OtherDetails1:
    'y': 'Yes'
    'n': 'No'
  OtherDetails2:
    'y': 'Yes'
    'n': 'No'
  OtherDetails3:
    'y': 'Yes'
    'n': 'No'
  OtherDetails4:
    'y': 'Yes'
    'n': 'No'
  OtherDetails5:
    'y': 'Yes'
    'n': 'No'
  OtherDetails6:
    'y': 'Yes'
    'n': 'No'

attr_list = {}

for attr, map of attr_maps
  attr_list[attr] = []
  for key, value of map
    attr_list[attr].push
      key: key
      value: value

expandValueUsingMap = (hash) ->
  hash[attr] = map[hash[attr]] for attr, map of attr_maps
  hash

filter = (req, res, next) ->
  debug "Citizen Auth Filter: #{req.url}"
  return res.redirect "/auth/signin?redirect=#{encodeURIComponent req.url}" unless req.session.user
  isCitizen req.session.user.email, (err, citizenValidity) ->
    unless citizenValidity
      if req.session.user
        res.redirect "/auth/signin"
      else
        res.redirect "/auth/signin?redirect=#{encodeURIComponent req.url}"
    next()

module.exports =
  Citizen: Citizen
  type: TYPE

  attr_maps: attr_maps
  attr_list: attr_list

  expandValueUsingMap: expandValueUsingMap
  filter: filter
  isCitizen: isCitizen
  addCitizen: addCitizen
  getForEmail: getForEmail
