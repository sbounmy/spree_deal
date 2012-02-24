module Spree::DealsHelper
  def t_unit_state(unit)
    unit_scope = [:inventory_unit_state]
    if deal = unit.variant.try(:product).try(:deal)
      unit_scope << :deal
      return t deal.state, :scope => unit_scope unless deal.complete?
      unit_scope << deal.state.to_sym
    else
      unit_scope << :base
    end
    t unit.state, :scope => unit_scope
  end
end
