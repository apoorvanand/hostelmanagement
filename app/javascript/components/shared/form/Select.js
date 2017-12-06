// @flow
import React from 'react';

type Props = {
  items: Object,
  currentValue: string,
  onChange: string => void,
};

const Select = ({ items, currentValue, onChange }: Props) => (
  <select value={currentValue} onChange={e => onChange(e.target.value)}>
    {Object.keys(items).map(value => (
      <option key={value} value={value}>
        {items[value]}
      </option>
    ))}
  </select>
);

export default Select;
