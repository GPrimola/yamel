defmodule Yamel.EncoderTest.EncodeStructTest do
  defstruct [:field1, :field2, :field3, field4: true]
end

defmodule Yamel.EncoderTest.EncodeDerivedStructTest do
  @derive {Yamel.Encoder, only: [:field4]}
  defstruct [:field1, :field2, :field3, field4: true]
end

defmodule Yamel.EncoderTest.EncodeDerivedExceptStructTest do
  @derive {Yamel.Encoder, except: [:field4]}
  defstruct [:field1, :field2, :field3, field4: true]
end
