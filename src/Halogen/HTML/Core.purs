module Halogen.HTML.Core
  ( HTML(..)
  , slot
  , text
  , element
  , keyed
  , prop
  , attr
  , handler
  , ref
  , class IsProp
  , toPropValue
  , PropName(..)
  , AttrName(..)
  , ClassName(..)
  , module Exports
  ) where

import Prelude

import DOM.HTML.Indexed.ButtonType (ButtonType, renderButtonType)
import DOM.HTML.Indexed.CrossOriginValue (CrossOriginValue, renderCrossOriginValue)
import DOM.HTML.Indexed.DirValue (DirValue, renderDirValue)
import DOM.HTML.Indexed.FormMethod (FormMethod, renderFormMethod)
import DOM.HTML.Indexed.InputAcceptType (InputAcceptType, renderInputAcceptType)
import DOM.HTML.Indexed.InputType (InputType, renderInputType)
import DOM.HTML.Indexed.KindValue (KindValue, renderKindValue)
import DOM.HTML.Indexed.MenuType (MenuType, renderMenuType)
import DOM.HTML.Indexed.MenuitemType (MenuitemType, renderMenuitemType)
import DOM.HTML.Indexed.OnOff (OnOff, renderOnOff)
import DOM.HTML.Indexed.OrderedListType (OrderedListType, renderOrderedListType)
import DOM.HTML.Indexed.PreloadValue (PreloadValue, renderPreloadValue)
import DOM.HTML.Indexed.ScopeValue (ScopeValue, renderScopeValue)
import DOM.HTML.Indexed.StepValue (StepValue, renderStepValue)
import DOM.HTML.Indexed.WrapValue (WrapValue, renderWrapValue)
import Data.Bifunctor (class Bifunctor, bimap, rmap)
import Data.Maybe (Maybe(..))
import Data.MediaType (MediaType)
import Data.Newtype (class Newtype, unwrap)
import Data.Tuple (Tuple)
import Halogen.Query.Input (Input)
import Halogen.VDom (ElemName(..), Namespace(..)) as Exports
import Halogen.VDom as VDom
import Halogen.VDom.DOM.Prop (ElemRef(..), Prop(..), PropValue, propFromBoolean, propFromInt, propFromNumber, propFromString)
import Halogen.VDom.DOM.Prop (Prop(..), PropValue) as Exports
import Unsafe.Coerce (unsafeCoerce)
import Web.DOM.Element (Element)
import Web.Event.Event (Event, EventType)

newtype HTML p i = HTML (VDom.VDom (Array (Prop (Input i))) p)

derive instance newtypeHTML :: Newtype (HTML p i) _

instance bifunctorHTML :: Bifunctor HTML where
  bimap f g (HTML vdom) = HTML (bimap (map (map (map g))) f vdom)

instance functorHTML :: Functor (HTML p) where
  map = rmap

-- | A smart constructor for widget slots in the HTML.
slot :: forall p q. p -> HTML p q
slot = HTML <<< VDom.Widget

-- | Constructs a text node `HTML` value.
text :: forall p i. String -> HTML p i
text = HTML <<< VDom.Text

-- | A smart constructor for HTML elements.
element :: forall p i. Maybe VDom.Namespace -> VDom.ElemName -> Array (Prop i) -> Array (HTML p i) -> HTML p i
element ns =
  coe (\name props children -> VDom.Elem ns name props children)
  where
  coe
    :: (VDom.ElemName -> Array (Prop i) -> Array (VDom.VDom (Array (Prop i)) p) -> VDom.VDom (Array (Prop i)) p)
    -> VDom.ElemName -> Array (Prop i) -> Array (HTML p i) -> HTML p i
  coe = unsafeCoerce

-- | A smart constructor for HTML elements with keyed children.
keyed :: forall p i. Maybe VDom.Namespace -> VDom.ElemName -> Array (Prop i) -> Array (Tuple String (HTML p i)) -> HTML p i
keyed ns = coe (\name props children -> VDom.Keyed ns name props children)
  where
  coe
    :: (VDom.ElemName -> Array (Prop i) -> Array (Tuple String (VDom.VDom (Array (Prop i)) p)) -> VDom.VDom (Array (Prop i)) p)
    -> VDom.ElemName -> Array (Prop i) -> Array (Tuple String (HTML p i)) -> HTML p i
  coe = unsafeCoerce

-- | Create a HTML property.
prop :: forall value i. IsProp value => PropName value -> value -> Prop i
prop (PropName name) = Property name <<< toPropValue

-- | Create a HTML attribute.
attr :: forall i. Maybe VDom.Namespace -> AttrName -> String -> Prop i
attr ns (AttrName name) = Attribute ns name

-- | Create an event handler.
handler :: forall i. EventType -> (Event -> Maybe i) -> Prop i
handler = Handler

ref :: forall i. (Maybe Element -> Maybe i) -> Prop i
ref f = Ref $ f <<< case _ of
  Created x -> Just x
  Removed _ -> Nothing

class IsProp a where
  toPropValue :: a -> PropValue

instance isPropString :: IsProp String where
  toPropValue = propFromString

instance isPropInt :: IsProp Int where
  toPropValue = propFromInt

instance isPropNumber :: IsProp Number where
  toPropValue = propFromNumber

instance isPropBoolean :: IsProp Boolean where
  toPropValue = propFromBoolean

instance isPropMediaType :: IsProp MediaType where
  toPropValue = propFromString <<< unwrap

instance isPropButtonType :: IsProp ButtonType where
  toPropValue = propFromString <<< renderButtonType

instance isPropCrossOriginValue :: IsProp CrossOriginValue where
  toPropValue = propFromString <<< renderCrossOriginValue

instance isPropDirValue :: IsProp DirValue where
  toPropValue = propFromString <<< renderDirValue

instance isPropFormMethod :: IsProp FormMethod where
  toPropValue = propFromString <<< renderFormMethod

instance isPropInputType :: IsProp InputType where
  toPropValue = propFromString <<< renderInputType

instance isPropKindValue :: IsProp KindValue where
  toPropValue = propFromString <<< renderKindValue

instance isPropMenuitemType :: IsProp MenuitemType where
  toPropValue = propFromString <<< renderMenuitemType

instance isPropMenuType :: IsProp MenuType where
  toPropValue = propFromString <<< renderMenuType

instance isPropOnOff :: IsProp OnOff where
  toPropValue = propFromString <<< renderOnOff

instance isPropOrderedListType :: IsProp OrderedListType where
  toPropValue = propFromString <<< renderOrderedListType

instance isPropPreloadValue :: IsProp PreloadValue where
  toPropValue = propFromString <<< renderPreloadValue

instance isPropScopeValue :: IsProp ScopeValue where
  toPropValue = propFromString <<< renderScopeValue

instance isPropStepValue :: IsProp StepValue where
  toPropValue = propFromString <<< renderStepValue

instance isPropWrapValue :: IsProp WrapValue where
  toPropValue = propFromString <<< renderWrapValue

instance isPropInputAcceptType :: IsProp InputAcceptType where
  toPropValue = propFromString <<< renderInputAcceptType

-- | A type-safe wrapper for property names.
-- |
-- | The phantom type `value` describes the type of value which this property
-- | requires.
newtype PropName value = PropName String

derive instance newtypePropName :: Newtype (PropName value) _
derive newtype instance eqPropName :: Eq (PropName value)
derive newtype instance ordPropName :: Ord (PropName value)

-- | A type-safe wrapper for attribute names.
newtype AttrName = AttrName String

derive instance newtypeAttrName :: Newtype AttrName _
derive newtype instance eqAttrName :: Eq AttrName
derive newtype instance ordAttrName :: Ord AttrName

-- | A wrapper for strings which are used as CSS classes.
newtype ClassName = ClassName String

derive instance newtypeClassName :: Newtype ClassName _
derive newtype instance eqClassName :: Eq ClassName
derive newtype instance ordClassName :: Ord ClassName
derive newtype instance semigroupClassName :: Semigroup ClassName
