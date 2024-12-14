defmodule SutraErpWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is set as the default
  layout on both `use SutraErpWeb, :controller` and
  `use SutraErpWeb, :live_view`.
  """
  use SutraErpWeb, :html

  embed_templates "layouts/*"
end
