# encoding: utf-8
module CollectiveIdea #:nodoc:
  module Acts #:nodoc:
    module NestedSet #:nodoc:
      # This module provides some helpers for the model classes using acts_as_nested_set.
      # It is included by default in all views.
      #
      module Helper
        # Returns options for select.
        # You can exclude some items from the tree.
        # You can pass a block receiving an item and returning the string displayed in the select.
        #
        # == Params
        #  * +class_or_item+ - Class name or top level times
        #  * +mover+ - The item that is being move, used to exlude impossible moves
        #  * +&block+ - a block that will be used to display: { |item| ... item.name }
        #
        # == Usage
        #
        #   <%= f.select :parent_id, nested_set_options(Category, @category) {|i|
        #       "#{'–' * i.level} #{i.name}"
        #     }) %>
        #
        def nested_set_options(class_or_item, mover = nil)
          class_or_item = class_or_item.roots if class_or_item.is_a?(Class)
          items = Array(class_or_item)
          result = []
          items.each do |root|
            result += root.self_and_descendants.map do |i|
              if mover.nil? || mover.new_record? || mover.move_possible?(i)
                [yield(i), i.id]
              end
            end.compact
          end
          result
        end

       # This method helps with building options_for_select for an object that has an association to a nested_set model
       # returns options_for_select with the following rules:
       # - class_or_item must be a class (or object of a class) that uses acts_as_nested_set
       # - items listed in excluded_items array will not be included in the list (to be used for items already associated to the object the drop down is for)
       # - all leaf nodes (ie items without sub-items) not included in the excluded_items array will appear in the drop-down and be selectable
       # - items that have children will be added to the list but will be disabled
       # - items with children who have ALL their children included in the excluded_items array will not be shown (as there are no selectable children)
  
       # example usage: <%= select :category, :id, nested_set_association_options_for_select(Item, @item.categories, "Select a category...") %>
  
       def nested_set_association_options_for_select(class_or_item, excluded_items=[], prompt="Please select..." )
    
         throw ArgumentError.new "nested_set_association_options_for_select - class_or_item must use acts_as_nested_set" unless class_or_item.respond_to?(:roots)
    
         def get_children(node, excluded_items = [] )
           result = []
           collection = nil
           if node.is_a?(Class)
             collection = Array(node.roots)
           else
             collection = Array(node.children)
           end
           collection.each do |child|
             if child.children.empty?
               result << ["#{ '-' * child.level} #{child.to_label}", child.id.to_s] unless excluded_items.include?(child)
             else
               children = get_children(child, excluded_items)
               unless children.empty?
                 @disabled << child.id.to_s
                 result << ["#{ '-' * child.level} #{child.to_label}", child.id.to_s]
                 result += children
               end
             end
           end
           result
         end
    
         result = [[prompt, ""]]
         @disabled = []
    
         result += get_children(class_or_item, excluded_items)    
    
         options_for_select(result, {:disabled => @disabled })
       end

      end
    end
  end
end
