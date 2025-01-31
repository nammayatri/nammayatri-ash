{-

  Copyright 2022-23, Juspay India Pvt Ltd

  This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

  as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

  is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

  the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module Components.SettingSideBar.View where

import Common.Types.App

import Animation (translateInXSidebarAnim, translateOutXSidebarAnim)
import Common.Types.App (LazyCheck(..))
import Components.SettingSideBar.Controller (Action(..), SettingSideBarState, Status(..), Tag(..), Item)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Engineering.Helpers.Commons (screenWidth, safeMarginBottom, safeMarginTop, os, isPreviousVersion)
import Font.Size as FontSize
import Font.Style as FontStyle
import Helpers.Utils (getAssetStoreLink, getCommonAssetStoreLink)
import Language.Strings (getString)
import Language.Types (STR(..))
import MerchantConfig.Utils (getMerchant, Merchant(..))
import MerchantConfig.Utils (getValueFromConfig)
import Prelude (Unit, const, unit, ($), (*), (/), (<>), (==), (||), (&&), (/=), map)
import PrestoDOM (Gravity(..), Length(..), Margin(..), Orientation(..), Padding(..), Visibility(..), PrestoDOM, visibility, background, clickable, color, disableClickFeedback, fontStyle, gravity, height, imageUrl, imageView, linearLayout, margin, onAnimationEnd, onBackPressed, onClick, orientation, padding, text, textSize, textView, width, weight, ellipsize, maxLines, imageWithFallback, scrollView, scrollBarY)
import PrestoDOM.Animation as PrestoAnim
import Storage (getValueToLocalStore, KeyStore(..), isLocalStageOn)
import Styles.Colors as Color
import Data.Maybe (Maybe(..))
import Helpers.Utils (getAssetStoreLink, getCommonAssetStoreLink)
import Common.Types.App (LazyCheck(..))
import Data.Array as DA
import Screens.Types (Stage(..))

view :: forall w .  (Action  -> Effect Unit) -> SettingSideBarState -> PrestoDOM (Effect Unit) w
view push state =
   linearLayout [
    width MATCH_PARENT
    , height MATCH_PARENT
    , orientation VERTICAL
    , clickable true
    , gravity BOTTOM
    , background Color.black9000
    , disableClickFeedback true
    , onClick push $ const OnClose
    , onBackPressed push $ const OnClose
    ][ PrestoAnim.animationSet
      [ translateInXSidebarAnim $ state.opened == OPEN
      , translateOutXSidebarAnim $ state.opened == CLOSING
      ] $ linearLayout
          [ height MATCH_PARENT
          , width WRAP_CONTENT
          , background state.appConfig.profileBackground
          , orientation VERTICAL
          , onAnimationEnd push $ if state.opened == CLOSING then const OnClosed else const NoAction
          , padding ( Padding 0 safeMarginTop 0 0 )
          ][  linearLayout
              [ width $ V ((screenWidth unit) / 10 * 8)
              , height MATCH_PARENT
              , background Color.white900
              , orientation VERTICAL
              , clickable true
              ][  profileView state push
                , scrollView
                  [ height MATCH_PARENT
                  , width MATCH_PARENT
                  , scrollBarY true
                  ]
                  [
                    settingsView state push
                  ]
                ]
            ]
      ]


------------------------------ settingsView --------------------------------
settingsView :: forall w. SettingSideBarState -> (Action -> Effect Unit) -> PrestoDOM (Effect Unit) w
settingsView state push =
  linearLayout
  [ height WRAP_CONTENT
  , width MATCH_PARENT
  , padding (Padding 18 24 18 8)
  , orientation VERTICAL
  ](map (\item -> 
        case item of
        "MyRides" -> settingsMenuView {imageUrl : "ic_past_rides," <> (getAssetStoreLink FunctionCall) <> "ic_past_rides.png", text : (getString MY_RIDES), tag : SETTINGS_RIDES, iconUrl : ""} push
        "Favorites" -> if DA.any (\stage -> isLocalStageOn stage)  [RideStarted, RideAccepted, RideCompleted] then emptyLayout else settingsMenuView {imageUrl : "ic_fav," <> (getAssetStoreLink FunctionCall) <> "ic_fav.png", text : (getString FAVOURITES)  , tag : SETTINGS_FAVOURITES, iconUrl : ""} push
        "EmergencyContacts" ->  if (isPreviousVersion (getValueToLocalStore VERSION_NAME) (if os == "IOS" then "1.2.5" else "1.2.1")) then emptyLayout
                                else settingsMenuView {imageUrl : "ny_ic_emergency_contacts," <> (getAssetStoreLink FunctionCall) <> "ny_ic_emergency_contacts.png" , text : (getString EMERGENCY_CONTACTS)  , tag : SETTINGS_EMERGENCY_CONTACTS, iconUrl : ""} push
        "HelpAndSupport" -> settingsMenuView {imageUrl : "ic_help," <> (getAssetStoreLink FunctionCall) <> "ic_help.png", text : (getString HELP_AND_SUPPORT), tag : SETTINGS_HELP, iconUrl : ""} push
        "Language" -> settingsMenuView {imageUrl : "ic_change_language," <> (getAssetStoreLink FunctionCall) <> "ic_change_language.png", text : (getString LANGUAGE), tag : SETTINGS_LANGUAGE, iconUrl : ""} push
        "ShareApp" -> settingsMenuView {imageUrl : "ic_share," <> (getAssetStoreLink FunctionCall) <> "ic_share.png", text : (getString SHARE_APP), tag : SETTINGS_SHARE_APP, iconUrl : ""} push
        "LiveStatsDashboard" -> if (isPreviousVersion (getValueToLocalStore VERSION_NAME) (if os == "IOS" then "1.2.5" else "1.2.1")) then emptyLayout
                                else settingsMenuView {imageUrl : "ic_graph_black," <> (getAssetStoreLink FunctionCall) <> "ic_graph_black.png", text : (getString LIVE_STATS_DASHBOARD), tag : SETTINGS_LIVE_DASHBOARD, iconUrl : "ic_red_icon," <> (getAssetStoreLink FunctionCall) <> "ic_red_icon.png"} push
        "About" -> settingsMenuView {imageUrl : "ic_info," <> (getAssetStoreLink FunctionCall) <> "ic_info.png", text : (getString ABOUT), tag : SETTINGS_ABOUT, iconUrl : ""} push
        "Logout" -> logoutView state push
        "Separator" -> separator
        _ -> emptyLayout
      ) state.appConfig.sideBarList
    )
getPreviousVersion :: String -> String 
getPreviousVersion _ = 
  if os == "IOS" then 
    case getMerchant FunctionCall of 
      NAMMAYATRI -> "1.2.5"
      YATRISATHI -> "0.0.0"
      _ -> "0.0.0"
    else do 
      case getMerchant FunctionCall of 
        YATRISATHI -> "0.0.0"
        _ -> "0.0.0"

separator :: forall w. PrestoDOM (Effect Unit) w
separator = linearLayout
      [ width MATCH_PARENT
      , height (V 1)
      , background Color.grey900
      , margin ( MarginVertical 8 8 )
      ][]
------------------------------ emptylayout --------------------------------
emptyLayout = linearLayout
              [ height $ V 0
              , width $ V 0
              , visibility GONE
              ][]
------------------------------ logoutView --------------------------------
logoutView ::  forall w. SettingSideBarState -> (Action -> Effect Unit) -> PrestoDOM (Effect Unit) w
logoutView state push =
  linearLayout
  [ height MATCH_PARENT
  , width MATCH_PARENT
  , orientation VERTICAL
  , margin ( MarginBottom 100 )
  ][ linearLayout
      [ width MATCH_PARENT
      , height (V 1)
      , background Color.grey900
      , margin ( MarginVertical 8 8 )
      ][]
  , settingsMenuView {imageUrl : "ic_logout," <> (getAssetStoreLink FunctionCall) <> "ic_logout.png", text : (getString LOGOUT_), tag : SETTINGS_LOGOUT, iconUrl : ""} push
    ]

------------------------------ profileView --------------------------------
profileView :: forall w. SettingSideBarState -> (Action -> Effect Unit) -> PrestoDOM (Effect Unit) w
profileView state push =
  linearLayout
  [ width MATCH_PARENT
  , height WRAP_CONTENT
  , background state.appConfig.profileBackground
  , gravity CENTER_VERTICAL
  , padding (Padding 18 24 0 24)
  -- , onClick push (const EditProfile) TODO :: add profile view in future
  ][ imageView
      [ width ( V 48 )
      , height ( V 48 )
      ,imageWithFallback $ "ny_ic_user," <> (getAssetStoreLink FunctionCall) <> "ny_ic_user.png"
      , onClick push $ (const GoToMyProfile)
      ]
    , linearLayout
      [ width WRAP_CONTENT
      , height WRAP_CONTENT
      , orientation VERTICAL
      , padding (PaddingLeft 16)
      , onClick push $ (const GoToMyProfile)
      ][ linearLayout
          [ width WRAP_CONTENT
          , height WRAP_CONTENT
          , gravity CENTER
          , orientation HORIZONTAL
          , padding (PaddingRight 15)
          ][ textView
              ([ height WRAP_CONTENT
              , text if ((getValueToLocalStore USER_NAME) == "__failed" || (getValueToLocalStore USER_NAME) == "") then (getString USER) else (getValueToLocalStore USER_NAME)
              , color state.appConfig.profileName
              , margin (MarginRight 5)
              , ellipsize true
              , maxLines 1
              ] <> (if os == "IOS" then [ width (V (screenWidth unit /2))]else [weight 1.0]) <> FontStyle.body13 TypoGraphy)
            , imageView
              [ width $ V 22
              , height (V 22)
              , color state.appConfig.profileName
              , imageWithFallback $ "ny_ic_chevron_right_white," <> (getAssetStoreLink FunctionCall) <> "ny_ic_chevron_right_white.png"
              ]
          ]
        , textView $
          [ width WRAP_CONTENT
          , height WRAP_CONTENT
          , text ((getValueToLocalStore COUNTRY_CODE) <> " " <> (getValueToLocalStore MOBILE_NUMBER))
          , color state.appConfig.profileName
          ] <> FontStyle.paragraphText TypoGraphy
        , linearLayout[
          height WRAP_CONTENT
        , width WRAP_CONTENT
        , orientation HORIZONTAL
        , gravity CENTER_VERTICAL
        , margin $ MarginTop 4
        , visibility case profileCompleteValue state of
            "100" -> GONE
            _ -> VISIBLE
        ][textView $
          [ text $ (getString PROFILE_COMPLETION) <> ":"
          , width WRAP_CONTENT
          , height WRAP_CONTENT
          , color state.appConfig.profileCompletion
          ] <> FontStyle.body3 TypoGraphy
        , imageView
          [ imageWithFallback case profileCompleteValue state of
              "50" -> "ic_50_percent," <> (getAssetStoreLink FunctionCall) <> "ic_50_percent.png"
              "75" -> "ic_75_percent," <> (getAssetStoreLink FunctionCall) <> "ic_75_percent.png"
              _    -> ""
          , height $ V 10
          , width $ V 10
          , margin $ Margin 4 4 4 2
          ]
        , textView $
          [ width WRAP_CONTENT
          , height WRAP_CONTENT
          , color state.appConfig.profileCompletion
          , text $ (profileCompleteValue state) <> " %"
          ] <> FontStyle.body3 TypoGraphy
        ]
      ]]

------------------------------ settingsMenuView --------------------------------
settingsMenuView :: forall w. Item -> (Action -> Effect Unit) -> PrestoDOM (Effect Unit) w
settingsMenuView item push  =
  linearLayout
  [ height WRAP_CONTENT
  , width MATCH_PARENT
  , gravity CENTER_VERTICAL
  , disableClickFeedback false
  , padding (Padding 0 16 16 16 )
  , onClick push $ ( const case item.tag of
                              SETTINGS_RIDES          -> PastRides
                              SETTINGS_FAVOURITES     -> GoToFavourites
                              SETTINGS_HELP           -> OnHelp
                              SETTINGS_LANGUAGE       -> ChangeLanguage
                              SETTINGS_ABOUT          -> GoToAbout
                              SETTINGS_LOGOUT         -> OnLogout
                              SETTINGS_SHARE_APP      -> ShareAppLink
                              SETTINGS_EMERGENCY_CONTACTS       -> GoToEmergencyContacts
                              SETTINGS_LIVE_DASHBOARD -> LiveStatsDashboard)
  ][  imageView
      [ width ( V 25 )
      , height ( V 25 )
      , imageWithFallback item.imageUrl
      ]
    , textView $
      [ width WRAP_CONTENT
      , height WRAP_CONTENT
      , text item.text
      , color Color.charcoalGrey
      , padding (PaddingLeft 20)
      ] <> FontStyle.body13 TypoGraphy
    , imageView
      [ width ( V 8 )
      , height ( V 8 )
      , visibility if item.tag == SETTINGS_LIVE_DASHBOARD && getValueToLocalStore LIVE_DASHBOARD /= "LIVE_DASHBOARD_SELECTED" then VISIBLE else GONE
      , margin ( Margin 6 1 0 0)
      , imageWithFallback item.iconUrl
      ]
    ]

profileCompleteValue :: SettingSideBarState -> String
profileCompleteValue state =
    case state.email , state.gender of
      Nothing, Nothing  -> "50"
      Nothing, Just _   -> "75"
      Just _ , Nothing  -> "75"
      Just _ , Just _   -> "100"
