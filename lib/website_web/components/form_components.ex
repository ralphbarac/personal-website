defmodule WebsiteWeb.FormComponents do
  @moduledoc """
  Standardized form components for consistent validation and styling.
  """

  use Phoenix.Component
  import WebsiteWeb.CoreComponents

  @doc """
  Renders a standardized form field with consistent styling and validation.

  Provides consistent error display, field styling, and proper accessibility.

  ## Examples

      <.form_field field={f[:title]} label="Title" required>
        <.input field={f[:title]} type="text" placeholder="Enter title..." />
      </.form_field>
      
      <.form_field field={f[:description]} label="Description" help_text="Brief description of the item">
        <.input field={f[:description]} type="textarea" rows="3" />
      </.form_field>
  """
  attr :field, Phoenix.HTML.FormField, required: true
  attr :label, :string, required: true
  attr :required, :boolean, default: false
  attr :help_text, :string, default: nil
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def form_field(assigns) do
    errors = if Phoenix.Component.used_input?(assigns.field), do: assigns.field.errors, else: []
    has_errors = length(errors) > 0

    assigns = assign(assigns, :has_errors, has_errors)

    ~H"""
    <div class={["form-field", @class]}>
      <label
        for={@field.id}
        class={[
          "block text-sm font-medium mb-2",
          @has_errors && "text-red-700",
          !@has_errors && "text-slate-700"
        ]}
      >
        <%= @label %>
        <span :if={@required} class="text-red-500 ml-1">*</span>
      </label>

      <div class="input-wrapper">
        <%= render_slot(@inner_block) %>
      </div>

      <.field_help_text :if={@help_text && !@has_errors} text={@help_text} />
      <.field_errors :if={@has_errors} field={@field} />
    </div>
    """
  end

  attr :text, :string, required: true

  defp field_help_text(assigns) do
    ~H"""
    <p class="mt-2 text-sm text-slate-500">
      <%= @text %>
    </p>
    """
  end

  attr :field, Phoenix.HTML.FormField, required: true

  defp field_errors(assigns) do
    errors = if Phoenix.Component.used_input?(assigns.field), do: assigns.field.errors, else: []
    translated_errors = Enum.map(errors, &WebsiteWeb.CoreComponents.translate_error(&1))
    assigns = assign(assigns, :errors, translated_errors)

    ~H"""
    <div :if={@errors != []} class="mt-2">
      <div :for={error <- @errors} class="flex items-start gap-2 text-sm text-red-600">
        <.icon name="hero-exclamation-circle-mini" class="h-4 w-4 mt-0.5 flex-shrink-0" />
        <span><%= error %></span>
      </div>
    </div>
    """
  end

  @doc """
  Renders a form section with consistent styling and spacing.

  ## Examples

      <.form_section title="Basic Information" description="Enter the basic details">
        <.form_field field={f[:title]} label="Title" required>
          <.input field={f[:title]} type="text" />
        </.form_field>
      </.form_section>
  """
  attr :title, :string, required: true
  attr :description, :string, default: nil
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def form_section(assigns) do
    ~H"""
    <div class={["bg-white rounded-lg shadow-sm border border-slate-200 p-6", @class]}>
      <div class="mb-6">
        <h3 class="text-lg font-medium text-slate-900"><%= @title %></h3>
        <p :if={@description} class="mt-1 text-sm text-slate-600"><%= @description %></p>
      </div>

      <div class="space-y-6">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  @doc """
  Renders form actions (submit, cancel buttons) with consistent styling.

  ## Examples

      <.form_actions>
        <:primary type="submit" phx-disable-with="Saving...">Save Post</:primary>
        <:secondary phx-click="cancel">Cancel</:secondary>
      </.form_actions>
  """
  slot :primary, required: true do
    attr :type, :string
    attr :phx_disable_with, :string
    attr :disabled, :boolean
    attr :class, :string
  end

  slot :secondary do
    attr :phx_click, :string
    attr :navigate, :string
    attr :class, :string
  end

  def form_actions(assigns) do
    ~H"""
    <div class="form-actions flex justify-end gap-3 pt-6 border-t border-slate-200">
      <button
        :for={secondary <- @secondary}
        type="button"
        phx-click={secondary[:phx_click]}
        {if secondary[:navigate], do: %{"phx-click" => "navigate", "phx-value-to" => secondary[:navigate]}, else: %{}}
        class={[
          "px-4 py-2 text-sm font-medium text-slate-700 bg-white border border-slate-300 rounded-lg hover:bg-slate-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-slate-500",
          secondary[:class]
        ]}
      >
        <%= render_slot(secondary) %>
      </button>

      <button
        :for={primary <- @primary}
        type={primary[:type] || "button"}
        phx-disable-with={primary[:phx_disable_with]}
        disabled={primary[:disabled]}
        class={[
          "px-4 py-2 text-sm font-medium text-white bg-emerald-600 border border-transparent rounded-lg hover:bg-emerald-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-emerald-500 disabled:opacity-50 disabled:cursor-not-allowed",
          primary[:class]
        ]}
      >
        <%= render_slot(primary) %>
      </button>
    </div>
    """
  end
end
