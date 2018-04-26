module Component.Task where

import Prelude

import Control.Monad.State as CMS

import Data.Maybe (Maybe(..))

import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP

import Model (Task)

-- | The task component query algebra.
data TaskQuery a
  = UpdateDescription String a
  | ToggleCompleted Boolean a
  | Remove a
  | IsCompleted (Boolean -> a)

data TaskMessage
  = NotifyRemove
  | Toggled Boolean

type TaskSlot = H.Slot TaskQuery TaskMessage

-- | The task component definition.
task :: forall m. Task -> H.Component HH.HTML TaskQuery Unit TaskMessage m
task initialState =
  H.component
    { initialState: const initialState
    , render
    , eval
    , receiver: const Nothing
    , initializer: Nothing
    , finalizer: Nothing
    }
  where

  render :: Task -> H.ComponentHTML TaskQuery () m
  render t =
    HH.li_
      [ HH.input
          [ HP.type_ HP.InputCheckbox
          , HP.title "Mark as completed"
          , HP.checked t.completed
          , HE.onChecked (HE.input ToggleCompleted)
          ]
      , HH.input
          [ HP.type_ HP.InputText
          , HP.placeholder "Task description"
          , HP.autofocus true
          , HP.value t.description
          , HE.onValueChange (HE.input UpdateDescription)
          ]
      , HH.button
          [ HP.title "Remove task"
          , HE.onClick (HE.input_ Remove)
          ]
          [ HH.text "✖" ]
      ]

  eval :: TaskQuery ~> H.HalogenM Task TaskQuery () TaskMessage m
  eval (UpdateDescription desc next) = do
    CMS.modify (_ { description = desc })
    pure next
  eval (ToggleCompleted b next) = do
    CMS.modify (_ { completed = b })
    H.raise (Toggled b)
    pure next
  eval (Remove next) = do
    H.raise NotifyRemove
    pure next
  eval (IsCompleted reply) = do
    b <- CMS.gets (_.completed)
    pure (reply b)
