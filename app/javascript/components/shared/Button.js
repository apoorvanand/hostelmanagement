// @flow
import * as React from 'react';
import styled from 'styled-components';

const ButtonRenderer = styled.button`
  display: inline-block;
  vertical-align: middle;
  margin: 0 0 1rem 0;
  padding: 0.85em 1em;
  -webkit-appearance: none;
  border: 1px solid transparent;
  border-radius: 0;
  -webkit-transition: background-color 0.25s ease-out, color 0.25s ease-out;
  transition: background-color 0.25s ease-out, color 0.25s ease-out;
  font-size: 0.9rem;
  line-height: 1;
  text-align: center;
  cursor: pointer;
  background-color: #286dc0;
  color: #fefefe;
  ${props =>
    props.disabled &&
    `
    cursor: not-allowed;
    opacity: 0.65
    `};
  ${props =>
    props.grey &&
    `
    background-color: #bbbbbb;
  `};
`;

const Button = ({ children, ...rest }: { children: ?React.Node }) => (
  <ButtonRenderer {...rest}>{children}</ButtonRenderer>
);

export default Button;
