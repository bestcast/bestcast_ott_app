class AppConfig {
  static const String BaseUrl = "https://bestcast.co";
  // static const String BaseUrl = "http://staging.bestcast.co";

  static const String encryptionKey = '5A4B3C2D1E0DSS';

  static const String rootUrl = "$BaseUrl/api/";
  static const String LoginUrl = "${rootUrl}login";
  static const String registerUrl = "${rootUrl}register";
  static const String emailverifyUrl = "${rootUrl}emailverify";
  static const String sendOtp = "${rootUrl}send-otp";
  static const String verifyOtp = "${rootUrl}login-with-otp";
  static const String loginbyqrcode = "${rootUrl}loginbyqrcode";

  static const String userProfileList = "${rootUrl}userprofilelist";
  static const String profileIconList = "${rootUrl}profileiconlist";
  static const String setUserProfile = "${rootUrl}setuserprofile/";
  static const String deleteUserProfile = "${rootUrl}deleteuserprofile/";
  static const String getUserDetails = "${rootUrl}user";
  static const String logoutUrl = "${rootUrl}logout";
  static const String deleteaAccountUrl = "${rootUrl}deleteuser";
  static const String setqrcode = "${rootUrl}setqrcode";
  static const String tokenexist = "${rootUrl}tokenexist";

  static const String bannerlist = "${rootUrl}guest/bannerlist?page_id=";
  static const String bannerlist1 = "${rootUrl}guest/bannerlist?page_id=";
  static const String searchMovieslist = "${rootUrl}guest/movieslist?search=";
  static const String genrelist = "${rootUrl}guest/genrelist";
  static const String usermovieslist = "${rootUrl}usermovieslist?profile_id=";
  static const String movieblockslist = "${rootUrl}guest/blockslist?page_id=";
  static const String popularMovieblockslist = "${rootUrl}guest/blockslist?page_id=4";
  static const String userMovieDetails = "${rootUrl}guest/getusermovie/";
  static const String userMainMovieDetails = "${rootUrl}getusermovie/";
  static const String setUserMovie = "${rootUrl}setusermovie/";
  static const String appnotifylist = "${rootUrl}guest/appnotifylist";
  static const String appnotifylistuser = "${rootUrl}appnotifylist";

  static const String subscriptionlist = "${rootUrl}subscriptionlist";
  static const String updatetransaction = "${rootUrl}updatetransaction";
  static const String verifypaymentstatus = "${rootUrl}verifypaymentstatus";
  static const String paymentgatewayinfo = "${rootUrl}paymentgatewayinfo";
  static const String createsubscription = "${rootUrl}createsubscription/";

  static const String privacyPolicy = "$BaseUrl/privacy-policy";
  static const String termsConditions = "$BaseUrl/terms-conditions";
  static const String pricingUrl = "$BaseUrl/pricing";
  static const String helpUrl = "$BaseUrl/help";
  static const String myAccountUrl = "$BaseUrl/my-account/";
  static const String myAccountLoginUrl = "$BaseUrl/accountlogin/";
  static const String forgotPassword = "$BaseUrl/password/reset";

  static const String getQuiz = "${rootUrl}moviequiz";
  static const String submitQuiz = "${rootUrl}mobilesubmitquiz";
  static const String quizResult = "${rootUrl}mobilequizresult";
  static const String rewardClaimCreate = "${rootUrl}reward-claim";
  static const String rewardClaimUpdate = "${rootUrl}reward-claim/";
}
